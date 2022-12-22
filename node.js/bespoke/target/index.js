import * as sdk from "microsoft-cognitiveservices-speech-sdk";
import * as https from "https";
/* import * as http from "http"; */
import * as fs from "fs";

/* ============================================================================= */

/* Not sure why this is not part of the standard library
   https://codereview.stackexchange.com/a/187875/139928
*/
function partitionArray(array, predicateFn) {
    return array.reduce(
        ( acc, curr ) =>
            {
                const accIndex = ( predicateFn(curr) ) ? 0 : 1;
                acc[accIndex].push(curr);
                return acc;
            },
        [ [], [] ]
    );
}

function falsyToEmptyString(maybeFalsy) {
    return maybeFalsy ? maybeFalsy : '';
}

function stripPeriod(itemProperty) {
    const notFalsyItemProperty = falsyToEmptyString(itemProperty);
    return notFalsyItemProperty.replace(/\.(\s|\*|†)*$/, '');
}

/*
A handy oneliner to get all the prices in an array from a Target weekly flyer but it works for any other prop as well

JSON.parse(document.body.textContent).pages.reduce( (acc, page) => { return page.hotspots.reduce( (icc, item) => { return icc.concat(item.price) }, acc ) }, [])
*/
function massagePrice(itemPrice) {
    if ( !itemPrice ) {
        return falsyToEmptyString(itemPrice);
    }

    // Because some `price` strings have the dollar sign and some do not so making this consistent.
    const preprocessedStr =
        itemPrice.
            replace(/\$/g, '').
            replace(/\/mo\./, ' per month').
            replace(/\/lb\./, ' per pound').
            replace(/BOGO/, 'buy one get one for').
            replace(/&/g, ' and ').
            replace(/\//, ' for $');

    let stringOrArray;

    if (preprocessedStr.match(/-/)) {
        const fromTo = preprocessedStr.split(/-/);
        stringOrArray = [ "from", fromTo[0], "to", fromTo[1] ];
    } else if (preprocessedStr.match(/[%$]/)) {
        /* Price strings with % in them so far didn't have clauses that required adding a dollar sign. If there are $ characters found at this point, those are the "x for $y" strings (see first and last `replace` above).
        */
        return preprocessedStr;
    } else if (preprocessedStr.match(/free/)) {
        // TODO This one is only to accomodate "But 2 get 1 free"; this text format may change in the future so keep an eye out.
        return preprocessedStr;
    } else {
        stringOrArray = preprocessedStr.split(/\s+/);
    }

    return stringOrArray.map( (pricePart) => { return (Number(pricePart)) ? `$${pricePart}` : pricePart; } ).join(' ');
}

function formatFinePrint(finePrint) {

    let newFinePrint =
        finePrint.
        /* The purpose of this is to be able to filter out 'Expect More. Pay Less.` from `page_description` on the "company messaging" page. */
        replace(/(More|Less)\./g, '').
        replace(/No. /g, 'Product number: ').
        /* replace(/\/mo\./g, ' per month'). */
        split(/(\.\s+|\*|†)/).
        filter( str => !str.match(/(©|reserved|trademark|property|countr)/i) ).
        filter( str => str.length > 5 ).
        filter( str => !str.match(/Target Circle/) ).
        filter( str => !str.match(/help\.target\.com/g) ).
        join('; ');

    //if ( newFinePrint.length < 10 ) { console.log(newFinePrint.length); }

    if (newFinePrint.length > 1000) {
        return '';
    } else {
        return (newFinePrint.length === 0) ? '' : `; Fine print: ${newFinePrint}`;
    }
}

function makeItemScript(item) {
  const newTitle = stripPeriod(item.title);
  const newPrice = massagePrice(item.price);
  const newProductDescription = stripPeriod(item.product_description /* .replace(/\.\s+/g, '; ') */ );
  const newFinePrint = formatFinePrint(item.fine_print);

  const template = `${newTitle}; ${newPrice}; ${newProductDescription}${newFinePrint}. `;

  return template.
      replace(/BOGO/g, 'Buy one get one ').
      replace(/\s*[†•]\s*/g, '; ').
      replace(/;\s*;/g, ';'). /* If product_description is empty, this can happen. */
      replace(/;\s*\./g, '.'). /* If price is empty, then there will be a dangling semicolon. */
      replace(/\s+/g, ' ').
      replace(/\s+\./g, '.').
      replace(/\.\./g, '.').
      replace(/\*/g, '').
      replace(/\.;/g, ';').
      //replace(/;\s*Fine print:\s*\./,'.').
      replace(/-pc\./g, '-piece').
      replace(/-pk\./g, '-pack').
      replace(/-qt\./g, '-quart').
      replace(/-ct\./g, '-count').
      replace(/-oz\./g, '-ounce').
      replace(/\/lb\./g, '$ per pound').
      replace(/\/lb/g, '$ per pound').
      replace(/\/mo\./g, ' per month').
      replace(/\/mo/g, '$ per month').
      replace(/-in\./g, '-inch').
      replace(/-pt\./g, '-pint').
      replace(/-fl\./g, '-fluid').
      replace(/-lb\./g, '-pound').
      replace(/([0-9]+)\/\$/g, "$1 for $").
      /* The Azure TTS REST API chokes on the replaced characters below. */
      replace(/\&/g, ' and ').
      replace(/™/g, ' ');
}

function pluralize(itemNumber) {
    return `${itemNumber} ${( itemNumber > 1 ) ? 'items' : 'item'}`;
}

function massagePageDescription(desc) {
    return desc.
        replace(/BEV/g, 'beverages').
        replace(/SNC/g, 'novelty candies').
        replace(/NIT/g, '').
        split(',').
        filter( (v, i, a) => a.indexOf(v) === i).
        join('; ');
}

/* Excluding `promotion_message` because it is always included in the `product_description`.
*/
function parseFlyer(jsonString) {
  return JSON.parse(jsonString).pages.
    /* Pages that start with a capital letter are advertising Target services, but the data in the JSON alone is not sufficient to create a coherent narrative (for now, but will keep an eye out), and will not go into experimenting with OCR for only these couple of pages.
       NOTE: The `page_description` for these pages contain the string "company messaging", but won't use that as filter condition because we need the last one, that states how long the flyer is valid for, and other details, and want to use that as the first audio. */
    filter( ( page ) => { return Number(page.indd_page_number) } ).
    map(
      ( page ) =>
        {
          let newItems =
            page.hotspots.
              /* When there is only a `title` and `price` and `page_description` are missing, usually the item is just a page blurb.
                 NOTE: This may filter out more than it should, so keep an eye out.
              */
              filter( ( item ) => { return [!!item.title, !!item.price, !!item.product_description].filter(i => i).length > 1 } ).
              map(
                ( item ) =>
                  {
                    return {
                      tts_item_script: makeItemScript(item),
                      original_properties: {
                        title: item.title,
                        price: item.price,
                        product_description: item.product_description,
                        fine_print: item.fine_print,
                        /* promotion_message: item.promotion_message */
                      }
                    };
                  }
              );

          return {
            items: newItems,
            tts_page_script: `${massagePageDescription(page.page_description)}; ${pluralize(page.hotspots.length)} on this page. `,
            original_properties: {
              page_description: page.page_description,
              indd_page_number: page.indd_page_number
            }
          };
        }
    );
}

   // let ff = Object.keys(f).reduce( (accArray, page_no) => { return accArray.concat(f[page_no])}, [] );

/* f.map( (page, i) => `Page ${i+1}: ${page.tts_page_script} ${ page.items.reduce( (acc, item) => { return acc + item.tts_item_script},"") }`. */
/*  ). */
/* forEach( e => console.log(e)); */

//Object.keys(f);


    //filter( pageArray => pageArray.filter( item => item.product_description.match(/wiffer/) ).length > 0 )

    //map( pageArray => pageArray.filter( item => !(!!item.price) ) )

     //reduce( (acc, pageArray) => { return acc.concat(pageArray.map( item => { console.log(item.tts_item_script);  return item.tts_item_script} ))}, []).filter( str => str.match(/brief/i) )//.forEach( i => console.log(i) )

    /* To print the text to be read (it would have probably been easier to `map` tts_item_script + join('') */
    /*
    reduce(
        (acc, pageArray) => {
            return acc + pageArray.reduce( (acc, item) => { return acc + item.tts_item_script }, "")
        },
        ""
    )
*/

function convertPageItemsToString( items ) {
  return items.
    reduce(
      (acc, item) =>
        { return acc + item.tts_item_script; },
      ""
    );
};
/* ============================================================================= */

function convertToAudio(str, outputPath) {

  // The     environment    variables     named
  // "SPEECH_KEY"   and   "SPEECH_REGION"   are
  // needed  for this;  currently calling  this
  // script with:
  //
  //     SPEECH_REGION="<azure_region>" SPEECH_KEY="<azure_speech_services_key>" node index.js

  // Azure Speech JavaScript SDK docs:
  // https://learn.microsoft.com/en-us/javascript/api/microsoft-cognitiveservices-speech-sdk

  const speechConfig = sdk.SpeechConfig.fromSubscription(process.env.SPEECH_KEY, process.env.SPEECH_REGION);
  const audioConfig = sdk.AudioConfig.fromAudioFileOutput(outputPath);

  // The language of the voice that speaks.
  speechConfig.speechSynthesisVoiceName = "en-US-JennyNeural";

  // Create the speech synthesizer.
  var synthesizer = new sdk.SpeechSynthesizer(speechConfig, audioConfig);

  /* return synthesizer.buildSsml(str); */

  synthesizer.speakTextAsync(
    str,
    function (result) {
      if (result.reason === sdk.ResultReason.SynthesizingAudioCompleted) {
        console.log("synthesis finished.");
      } else {
        console.error("Speech synthesis canceled, " + result.errorDetails +
            "\nDid you set the speech resource key and region values?");
      }
      synthesizer.close();
      synthesizer = null; // Why is closing it not enough?
    },
    function (err) {
      console.trace("err - " + err);
      synthesizer.close();
      synthesizer = null;
    }
  );

  console.log("Now synthesizing to: " + outputPath);
}

(function() {

  "use strict";

  /* The `import`s would not work inside the body of the function for some reason, so had to move them to the top when replacing the `require`s
  */
  /* var sdk = require("microsoft-cognitiveservices-speech-sdk"); */
  /* var readline = require("readline"); */

  /* http.request('http://localhost:4000', (res) => { */
  const url = 'https://api.target.com/weekly_ads/v1/promotions/3306-20221218?key=9ba599525edd204c560a2182ae1cbfaa3eeddca5';

  https.get(
    url,
    (res) =>
      {
        res.setEncoding('utf-8');
        let rawData = '';

        res.on(
          'data',
          (chunk) =>
            {
              rawData += chunk;
              // https://stackoverflow.com/a/11267583/1498178
              // (Do note the caveat at the bottom; so if this is something way larger, probably `createWriteStream` is the way to go:
              // https://stackoverflow.com/a/43370201/1498178
              /* fs.appendFile('target_2022-12-18.json', chunk, (err) => { */
              /*   if (err) { throw err; } */
              /*   console.log(`This chunk (length: ${chunk.length}) is written.`); */
              /* }); */
              /* console.log(chunk); */
              /* console.log(process.cwd()); */
              /* console.log(typeof chunk); */
            }
        );

        res.on(
          'end',
          () =>
            {
              /* const str = parseFlyer(rawData)[0].tts_page_script; */

              /* This juggling around is to put a "company messaging" page stating the flyer validity up top, instead of it being the last page (usually). There is a filter above getting rid of pages with capital letters as page numbers (see note there also), but these also have "company messaging" in the page_description, so they may also be relevant...
              */
              const parsedFlyer = parseFlyer(rawData);

              const [ companyMessaging, regularPages ] =
                partitionArray(
                  parsedFlyer,
                  ( page ) =>
                    {
                      return page.original_properties.page_description.match(/company messaging/);
                    }
                );

              const pageScripts =
                regularPages.
                  map( (page, i) =>
                    {
                      return `Page ${ i+1 }: ${ page.tts_page_script } ${ convertPageItemsToString(page.items) }`
                    }
                  );

              companyMessaging.
                map ( ( page ) => { return convertPageItemsToString(page.items); } ).
                concat( pageScripts ).
                /* slice(0,5). */
                forEach( e => console.log(e) )
                /* forEach( ( pageString, i ) => convertToAudio(pageString, `page_${String(i+1).padStart(2,'0')}.wav`)); */
            }
        );
      }
  );

}());

