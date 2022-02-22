const url = new URL(Deno.args[0]);
// console.log(url.toString());
// console.log(url.search);
// url.search = new URLSearchParams(url.search).toString();
// console.log(url.search);
const res = await fetch(url);
const json = await res.json();
// const body = new Uint8Array(await res.arrayBuffer());
// const json = JSON.parse(body);
// await Deno.stdout.write(res.json());
// console.log(json);

const util = {};
// https://betterprogramming.pub/compose-and-pipe-in-javascript-medium-d1e1b2b21f83
util.pipe =
  function(...functions) {
    return function(x) {
      return functions.reduce( (acc, fn) => fn(acc), x);
    }
  }
;

// TODO: this not necessarily needed as `stringify/1` is not bothered by extraneous properties and will use the one's are needed; it is mostly good for the human eyes during test runs
// Remove all the properties not enumerated in `neededKeys`
function cullItemProps(item) {

  const neededKeys =
    [ 'description'
    , 'disclaimer'
    , 'name'
    , 'page'
    , 'post_price_text'
    , 'pre_price_text'
    , 'price_text'
    , 'sale_story'
    ]
  ;

  const doFilter =
    (accObj, currentKey) => ({ ...accObj, [currentKey]: item[currentKey] })
    // or
    //   function(accObj, currentKey) {
    //     accObj[currentKey] = item[currentKey];
    //     return accObj;
    //   }
  ;

  return neededKeys.reduce(doFilter, {});
}

// TODO: Make it SSML instead? Or, another function because `stringify/1` could be just swapped out in `const transforms` below
function stringify(item) {

  return item.name
       + ", "

       + (item.description ?? "")
         .replaceAll("\n", " ")
         .replaceAll("-oz.", " ounce")
         .replace("ea.", "each")
       + ", "

       + item.pre_price_text

       + (item.price_text ? ` \$${item.price_text}` : "")
       + " "

       + (item.post_price_text ?? "")
         .replace(/^ea.*$/, "each, member price")
         .replace(/^lb.*$/, "per pound, member price")
       + ". "

       + (item.sale_story ?? "")
         .replace(/member price/i, "")
       + ". "

       + (item.disclaimer ?? "")
         // .split("\n")
         // .sort()
         // .filter(line => !line.match(/for u/i))
         // .filter(line => line.length)
         // .join(". ")
         // to filter out lines like
         // "Safeway   for  U™   coupon  must
         //  be  present  at   check  out  or
         //  downloaded to your account prior
         //  to  purchase.  LIMIT ONE  Coupon
         //  per  Household per  Day. Expires
         //  1/25/22."
       ;
}

// In short:
// =========
//   (1) Strip "Coupon" from an item's `category` property
//   (2) Remove coupon-related long texts
//
// At length:
// ==========
// Each  item has  a `categories`  array property  that
// (usually)  contains  the  following  combination  of
// items:
//
//   (1) empty array (`[]`):
//       This is to promote non-product-related offers; don't
//       need these as they usually refer to online stuff
//
//   (2) `[ 'Coupon' ]`:
//       similar  to  item  one,  thus  not  needed  for  our
//       listeners
//
//   (3) `[ <name-of-a-category> ]`:
//       This is  ok (and  the next  section shows  why Flipp
//       went with an array here, instead of a simple string,
//       even though it still does not make much sense)
//
//   (4) `[ 'Coupon', <name-of-a-category> ]`:
//       This  usually  means  that the  `disclaimer`  string
//       property  will contain  superfluous text  (at least,
//       from  the  point  of  our listeners  view)  such  as
//       "Safeway for U™ coupon must  be present at check out
//       or  downloaded to  your account  prior to  purchase.
//       LIMIT  ONE Coupon  per  Household  per Day.  Expires
//       1/25/22.",  instead of  the  useful short  sentences
//       such as "Limit 2 per item." etc.

function stripCouponsFrom(adItem) {

  adItem.categories =
    adItem
    .categories
    .filter(c => c !== "Coupon")
  ;

  adItem.disclaimer =
    (adItem.disclaimer ?? "")
      .split("\n")
      .sort()
      .filter(line => !line.match(/for u/i))
      .filter(line => line.length)
      .join(". ")
  ;

  return adItem;
}

function transformItemAndPushToCategoryWith(transforms) {

  return function(accObj, currentItem) {

    const category =
      stripCouponsFrom(currentItem)
      .categories
      .join()
      // Using   `toString()`  would   have   been  just   as
      // good  as  these  are 1-element  arrays  because  (1)
      // `stripCouponsFrom/1` already  filtered out "Coupons"
      // and (2) have  never seen an item  belong to multiple
      // categories  (and it  also doesn't  makes sense,  but
      // that's not a strong argument...)
    ;

    // Read comment above `stripCouponsFrom/1` but the gist
    // is that  anything that  resolves to an  empty string
    // category  is a  coupon (hopefully)  and thus  can be
    // dismissed
    if ( category === "" ) {
      return accObj;
    }

    if ( !accObj.hasOwnProperty(category) ) {
      accObj[category] = [];
    }

    util.pipe
      // ( cullItemProps
      // , stringify
      ( ...transforms
      , transformedItem => accObj[category].push(transformedItem)
      )
      ( currentItem )
    ;

    return accObj;
  }
}

function groupByCategoriesAndDo(transforms) {
  return function (items) {
    return items.reduce(transformItemAndPushToCategoryWith(transforms), {})
  }
}


// const azRes =

// console.log(azRes);

// let g = f.reduce(groupByCategoriesAndDo, {});
const transforms =
  [ cullItemProps
  , stringify
  ]
;

let g =
  util.pipe
    ( // A Safeway-specific filter
      items =>
        items.filter
        (    item => item.categories.length !== 0
          || item.categories.join() !== "Coupon"
        )
    , groupByCategoriesAndDo(transforms)
    )
    (json)
;

// console.log(g);

// To compare the number of items in `f` and `g`:
// Object.keys(g).reduce( (acc, key) => acc + g[key].length, 0)

// TODO: define recording headers

// Splice string arrays under each category to make a TTS audio file per each category
// Object.keys(g).reduce( (accArr, categoryKey) => { accArr.push(`Current category: ${categoryKey}. ` + g[categoryKey].join(" ") + `End of ${categoryKey}.`); return accArr }, []).join(" ")


import { writableStreamFromWriter } from "https://deno.land/std@0.121.0/streams/mod.ts";

async function callAzureTTS(ssml) {

  const response =
    await fetch
      ( "https://westus2.tts.speech.microsoft.com/cognitiveservices/v1"
      , { method: "POST"
        , headers:
          { "Ocp-Apim-Subscription-Key": Deno.env.get("AZURE_SPEECH_KEY")
          , "Content-Type":              "application/ssml+xml"
          , "X-Microsoft-OutputFormat":  "audio-16khz-128kbitrate-mono-mp3"
          }
        , body: ssml
        }
      )
  ;

  return response;
}

async function saveResponseToFile(response, filename) {

  // Deno examples: saving files
  // https://deno.land/manual@v1.17.3/examples/fetch_data

  if (response.body) {
    const file = await Deno.open(filename, { write: true, create: true });
    const writableStream = writableStreamFromWriter(file);
    await response.body.pipeTo(writableStream);
  }
}

Object.keys(g).forEach(

  function (categoryKey) {

    const textToReadInCategory =
        `Current category: ${categoryKey}. `
      + g[categoryKey].join(" ")
      + `End of ${categoryKey}.`
    ;

    const ssml =
        "<speak version='1.0' xml:lang='en-US'>  <voice xml:lang='en-US' xml:gender='Male' name='en-US-EricNeural'>"
      + textToReadInCategory
      + "</voice> </speak>"
    ;

    console.log(ssml);

    const filename =
        new Date().toISOString().replaceAll(":", "-")
      + "-"
      + categoryKey.split(/[^a-zA-Z]/g).filter(w => w.length).join("-")
      + ".mp3"
    ;

    console.log();
    console.log(filename);
    console.log();
    console.log(ssml);

    callAzureTTS(ssml).then( resp => { console.log(resp); saveResponseToFile(filename, resp) } ).then( x => console.log(x));
    // const azResponse = await callAzureTTS(ssml);
    // console.log(azResponse);
    // await saveResponseToFile(azResponse, filename);
  }
)

// ["have you tried turning it off and on again?", "are you sure?", "smarties cereal"].forEach(
//   function (e,i,a) {
//     const ssml =
//         "<speak version='1.0' xml:lang='en-US'>  <voice xml:lang='en-US' xml:gender='Male' name='en-US-EricNeural'>"
//       + e
//       + "</voice> </speak>"
//     ;

//     callAzureTTS(ssml).then( resp => saveResponseToFile(resp, String(i))).then( x => console.log(x) );
//   }
// )
