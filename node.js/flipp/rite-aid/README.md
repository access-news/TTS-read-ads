## 0. Interim solution

### Step 0. Reload the page and scroll down manually

This was the only way the script in Step 1. below worked this week...

### Step 1. Scrape the weekly ad HTML to create a page template

On the [Rite Aid weekly ad](https://www.riteaid.com/weekly-ad) site, there is a `<button>` element for each item / special, and items on a page are in a plain `<div>` (literally just a `<div>...</div>` block). Each `<button>` has an `item_id` attribute that corresponds to the `id` in the JSON API, so once the scaffolding is done for a page.

The script below creates a 3-dimensional array (`[ /* page */ [ /* items */ [ /* item */ [..], [..] ]]]`) that needs to be copied from the browser tab / window to the one in the next step.

```javascript
/* ====================================== */
/* STEP 1. SCRAPE HTML TO CREATE TEMPLATE */
/* ====================================== */

pages = Array.from(document.querySelectorAll('sfml-flyer-image > div'));

/* There a pages that only have link children (i.e., `<a>`) and not
   `<button>`s, so those will come up as empty arrays. They can be
   ignored as these are the blue link collections to sections
   ("Shop your faves!") and the "Back to the top" button.

   Didn't see any point in saving the section names from one of the
   link collections, because there is no way to programmatically
   correlate with the items in any way. The JSON API has `categories`
   keys that don't correspond to these names (and are useless), and
   the titles are pure images, without any text markup referring to
   them. So, if I have to do some parts by hand, I might as well do
   all of them, and this way (hopefully) not miss any.
*/
items_per_page =
    pages.
        map( page => Array.from(page.querySelectorAll('button')) ).
        filter( array => array.length )
    ;

/* NOTE Decided to only save the product ids, because the
   `<button>` attribute texts seemingly are only a truncated
   version of the JSON API. Fingers crossed.
*/

flyer_template =
    items_per_page.map( page =>
        page.map ( item => [ Number(item.dataset.productId) /*, item.ariaLabel */])
    );

// copy(flyer_template);
```

### Step 2. Fill the page template from the JSON API

The script below is totatlly ad hoc; see rant below. Copy the script below into the dev console opened on the second link below (i.e., where all the items are listed). To get there:

1. Get the latest available flyer id (see `id` in the returned JSON)

   ```
   https://dam.flippenterprise.net/flyerkit/publications/riteaid?locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&show_storefronts=true&postal_code=95811&store_code=6520
   ```

2. Plug it into this link (where it says `<ID>`)

   ```
   https://dam.flippenterprise.net/flyerkit/publication/<ID>/products?display_type=all&valid_web_url=false&locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4
   ```

> RANT (in a Nick Offerman voice)
> The Flipp JSON API is a mess: missing / renamed object properties each week, the naming of the properties matter little (e.g., disclaimer stuff is regularly in other, unrelated properties, `categories` is totally useless and does not even correspond to the rendered section names), string duplication (e.g., `name` is sometimes contained in `description` verbatim), typos galore (even in obviously template text that should be just copied around, but seemingly all this is typed by hand...), representational elements in the strings (e.g., '\n'), etc.
>
>
> Not to mention that the Rite Aid site is grossly inaccessible (e.g., the headers of each section is only an image without any markup to indicate this), hence the need for Step 3.

```javascript
/* ===================================== */
/* STEP 2. FILL TEMPLATE FROM JSON API   */
/* ===================================== */

// flyer_structure = f = <copy>

const pick = (obj, needed_keys) => needed_keys.filter(key => key in obj).reduce((obj2, key) => (obj2[key] = obj[key], obj2), {});

/* NOTE `disclaimer` vs `disclaimer_text`

   The returned JSON seems to have a different structure from week to week
   (e.g., no `page` property this week), and there was no `disclaimer` prop
   yesterday - but there is one today. (Also, `disclaimer` seems to be the
   the canonical one, but who knows.)

   Bottom line: if fails to run, check the properties/keys/whatever.
*/
needed_keys = [
    'name',
    'description',
    'pre_price_text', 'price_text', 'post_price_text',
    'disclaimer', /* 'disclaimer_text', */
    'sale_story'
]

jsonItems = JSON.parse($0.textContent);

//toLocaleString('default', { month: 'long' })

filled =
    f.map( (page, i) => {
        newPage = page.map( item => {
            tempItem = jsonItems.find( i => i.id === item[0]);
            newItem = pick(tempItem, needed_keys);
        //  newItem['ariaLabel'] = item[1];
            return newItem;
        });
        return [ `Page ${i+1}; PAGETITLEPLACEHOLDER` ].concat(newPage);
    });

filled_joined =
    filled.map( page => {
        joinedPage = page.map( item => {
            joinedItem = needed_keys.reduce(
                (acc, next) => {
                    i = item[next] ? item[next] : '';
                    switch (next) {
                        case 'price_text':
                            i = i ? '$' + i : i;
                            break;
                        case 'name':
                            // `description` sometimes starts with the same string that is in `name`. To check:
                            // filled_joined.reduce( (acc, page) => { return acc.concat(page.filter( item => item.description && item.name && item.description.match(new RegExp(item.name))) ) }, [])
                            i = (item.description && item.description.match(new RegExp(i))) ? '' : i;
                            // NO BREAK!
                        case 'description':
                            i = i.replaceAll(/\n+/g, ' ');
                            break;
                        default:
                            i;
                    }
                    return acc + '; ' + i;
                },
                "");

            item['proposed_text'] =
                joinedItem.
                    replace(/^(\s*;\s*)+/, '').
                    replaceAll(/\n+/g, '; ').
                    replaceAll(/oz\./g, 'ounce').
                    replaceAll(/ct\./g, 'count').
                    replaceAll(/[Ee][Aa]\./g, 'each').
                    replaceAll(/¢/g, '').
                    replaceAll(/ml\./g, 'milliliters').
                    replaceAll(/(\d+)\/(\s?)*;/g, '$1 for ').
                    replaceAll(/((\*?)*[Ll]imit\s+\d)/g, '; $1 ;').
                    replaceAll(/(bonuscash) buy/ig, '$1 if you buy').
                    replaceAll(/(;\s*)+[Oo][Rr]/g, ' or').
                    replaceAll(/clip coupon now\!?/ig, 'with coupon').
                    replaceAll(/(;\s*)+with/ig, ' with').
                    replaceAll(/\*+/g, '').
                    replaceAll(/(riteaid.com\/coupons)/ig, '; see $1 ;').
                    replaceAll(/(;\s*)*sunday\s+paper/ig, ' with Sunday paper').
                    replaceAll(/\.;/g, '; ').
                    replace(/(;\s*)*$/, '')

            return item;
        });
        return joinedPage;
    });

// Appending the "T..." string is needed otherwise JS will subtract 1
// from the day for reasons only known to god.
from = new Date(JSON.parse($0.textContent)[0].valid_from + "T00:00:00");
to   = new Date(JSON.parse($0.textContent)[0].valid_to   + "T00:00:00");

fromMonthName = from.toLocaleDateString('default', { month: 'long' });
toMonthName   =   to.toLocaleDateString('default', { month: 'long' });

fromDayName = from.toLocaleDateString('default', { weekday: 'long' });
toDayName   =   to.toLocaleDateString('default', { weekday: 'long' });

fromDateNumber = from.getDate();
toDateNumber   =   to.getDate();

header = `Rite Aid. Specials are valid from ${fromMonthName} ${fromDateNumber}, ${fromDayName}, to ${toMonthName} ${toDateNumber}, ${toDayName}.`

j = header + "\n" + filled_joined.map( page => page.map( item => { return typeof item.proposed_text === 'string' ? item.proposed_text : item }).join('. ')).join('. End of page.\n')
```

### Step 3. Fill out the blanks + correct one-off errors

There is `PAGETITLEPLACEHOLDER` at the moment (and a lots of typos, probably).

---

1. Get the latest available flyer id (see `id` in the returned JSON)

   ```
   https://dam.flippenterprise.net/flyerkit/publications/riteaid?locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&show_storefronts=true&postal_code=95811&store_code=6520
   ```

2. Plug it into this link (where it says `<ID>`)

   ```
   https://dam.flippenterprise.net/flyerkit/publication/<ID>/products?display_type=all&valid_web_url=false&locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4
   ```

3. Run one of the scripts below

   ... and hope that one will work.

   The first one stopped working right after the first week, because next week's JSON didn't have the `page` key (which was used to corral the products on their respective pages for sorting), missing a bunch of others, and some were renamed (e.g., `disclaimer` to `disclaimer_text`). The next one is based on the `categories` key; the downside is that it does not correspond to the headers of the flyer at all, and I think some of the products are even uncategorized, but we'll have to work with what we got.

### 0.1 The one using the `page` key <!-- {{- -->

```javascript
/*

flyer sections => `item.page_destination !== null`
==================================================

Items with `page_destination` are the sections in the flyer; the `categories` lists seem arbitrary for each item, and didn't prove to be reliable. With `page_destination`s, the flow of the visual flyer representation can be followed (more or less).

`page_destination` is always the same for every "section item":

   JSON.parse($0.textContent).filter( item => item.categories.length === 0 ).reduce( (acc, item) => { if (acc[item.name]) { acc[item.name].pages.add(item.page); acc[item.name].dests.add(item.page_destination); acc[item.name].cats = new Set([...item.categories, ...acc[item.name].cats]); } else { acc[item.name] = { 'pages': (new Set()).add(item.page), 'dests': (new Set()).add(item.page_destination), 'cats': new Set([...item.categories]) } }; return acc; }, {})

   JSON.parse($0.textContent).filter( item => item.page_destination !== null ).reduce( (acc, item) => { if (acc[item.name]) { acc[item.name].pages.add(item.page); acc[item.name].dests.add(item.page_destination); acc[item.name].cats = new Set([...item.categories, ...acc[item.name].cats]); } else { acc[item.name] = { 'pages': (new Set()).add(item.page), 'dests': (new Set()).add(item.page_destination), 'cats': new Set([...item.categories]) } }; return acc; }, {})

> NOTE "Back to the top"
> Always "links" to the 1st page and can be ignored or liberties taken with it. For example, Deals of the Week starts on page 3, but specials leading up to it take no special designation, so they can be merged into it - or just let them stay alone.

products  => `item.page_destination === null && item.categories.length !== 0`
============================================================================

This is the inverse of flyer sections plus the last part filters out "Rite Aid" items, which have no informational content whatsoever, and seem to be there only as a placeholder (e.g., for when the flyer is generated, to show where to insert a half page logo).

*/

flyer_sections = JSON.parse($0.textContent).filter( item => item.page_destination !== null && item.name !== 'Rite Aid').reduce( (acc, section) => {  acc[section.page_destination] = [section.name]; return acc; }, {});

/*
Why not simply use `flyer_sections`? Its keys are the page numbers already.
> Because ordering in objects is not guaranteed by keys.
*/
section_starts = Object.keys(flyer_sections).filter( e => e !== 'null').map( e => Number(e)).sort( (a,b) => a-b);

/* this is simply for debugging */
products_per_page = JSON.parse($0.textContent).filter( item => item.page_destination === null && item.name !== 'Rite Aid' ).reduce( (acc, product) => { page = Number(product.page); if (acc[page]) { acc[page].push(product) } else { acc[page] = [ product ] }; return acc; }, []);

section_starts.push(products_per_page.length-1);

do { current_section = section_starts.shift(); page = current_section; next_section = section_starts[0]; do { flyer_sections[current_section] = flyer_sections[current_section].concat(products_per_page[page]); page++; } while ( page < next_section ) } while ( section_starts.length !== 1 )

product_keys_that_may_be_needed = ['brand', 'coupons', 'current_price' , 'current_price_range', 'description', 'disclaimer', 'dollars_off', 'item_type', 'name', 'original_price', 'original_price_range', 'percent_off', 'post_price_text', 'pre_price_text', 'price_text', 'sale_story', 'sub_items']

needed_product_keys = ['current_price' , 'current_price_range', 'description', 'disclaimer', 'dollars_off', 'item_type', 'name', 'original_price', 'original_price_range', 'percent_off', 'post_price_text', 'pre_price_text', 'price_text', 'sale_story', 'sub_items']

const pick = (obj, needed_keys) => needed_keys.filter(key => key in obj).reduce((obj2, key) => (obj2[key] = obj[key], obj2), {});
const null_to_string =  str => { if (str) { return str; } else { return ''; }};

debug_res = Object.keys(flyer_sections).map( key => flyer_sections[key]).map( e => e.filter( i => i ).map( (product, i, _arr) => { if ( i === 0 ) { return product; } else { return pick(product, needed_product_keys) }}));


res = Object.keys(flyer_sections).map( key => flyer_sections[key]).map( section => section.filter( i => i ).map( (product, i, _arr) => { if ( i === 0 ) { return product; } else {

    p = product;

    text = '';
    des = '';
    is_crv = false;

    if (p.description) {
        if (p.description.match(/\+CRV/)) {
            des = p.description.replace(/\+CRV[\s\S]*or[\s\S]*deposit[\s\S]*where[\s\S]*applicable/, '');
            is_crv = true;
        } else {
            des = p.description
        }
    }

    if (p.description && p.description.startsWith(p.name)) {
        text = text + des;
    } else {
        text = [ text, p.name, des ].join('; ');
    }

    text = text + '; ';

    /* This could have been way easier with `replaceAll` used with a capturing group... Such as
          replaceAll(/(\d)\//g, "$1 for ");
    */
    pre_match = p.pre_price_text.match(/(\d)\//);
    if (pre_match) {
        text = text + pre_match[1] + ' for $' + p.price_text + (is_crv ? ' plus CRV or deposit where applicable; ' : '')
    } else {
        if (p.current_price) {
            text = [text, p.pre_price_text, '$' + p.price_text].join(' ') + (is_crv ? ' plus CRV or deposit where applicable; ' : '')
        } else {
            text = text + '; ' + p.pre_price_text
        }
    }

    dis = '';
    if (p.disclaimer) {
        dis = p.disclaimer.replaceAll(/[Cc]lip[\s\S]*coupon[\s\S]*now[!\s\S]*riteaid[\s\S]*.[\s\S]*com\/coupons/g, ' with coupon (see riteaid.com/coupons); ');

        dis = dis.split(/([Ll]imit\s+\d)/);
        if (dis.length > 1) {
            dis = '; ' + dis[0] + ' ' + dis[2] + ' ' + dis[1] + '; ';
        } else {
            dis = '; ' + dis[0] + '; ';
        }

        dis = dis.split(/([Ww]it[\s\S]*[Rr]ite[\s\S]*[Aa]id[\s\S]*[Rr]ewards)/);
        if (dis.length > 1) {
            dis = '; ' + dis[1] + ' ' + dis[0] + ' ' + dis[2] + '; ';
        } else {
            dis = '; ' + dis[0] + '; ';
        }

    } else {
        dis = '';
    }

    sale = '';
    if ( p.sale_story ) {
        sale = p.sale_story.replaceAll(/[Bb]onus[Cc]ash.*[Bb]uy/g, 'BonusCash coupon if you buy ');
    } else {
        sale = '';
    }

    text = [ text, dis, sale ].join('; ');
    text = text + '. ';

    return text. /*replaceAll('\n', '\\n'). */
        replaceAll('\n', ' ').
        replaceAll(/(;\s+)+/g, '; ').
        replaceAll(/\.\s+;\s+\./g, '.').
        replaceAll(/;\s+\./g, '.').
        replace(/^;\s+/, '').
        replaceAll('ct.', 'count').
        replaceAll('oz.', 'ounce').
        replaceAll(/EA/g, ' each').
        replaceAll(/[;\s]*with/g, ' with ').
        replaceAll(/;\s+OR/g, ' or ').
        replace(/\.\s*\.?$/, '').
        trim()
        ; /* text.
        replaceAll(',\n', ', ').
        replaceAll('\nOR', ' or').
        replaceAll('\nor', ' or').
        replaceAll('\n', '; ').
        replaceAll('; with', ' with').
        replaceAll(/Rewards;\s+or/g, 'Rewards, or'); */

; } } ).join('. ') + '. End of section. '
) /*.join('\n') */

/* `price_text` always the same as `current_price`, but using the former, because it is an empty string when none, but the latter is `null`. */
```

<!-- }}- -->
### 0.2 The one using the `categories` key <!-- {{- -->

Again, don't use this; see NOTE above.

```javascript
/* SCRIPT BASED ON THE `categories` KEY */

// To test the pattern later:
//
// + products:   [ i>0, null, "a_string" ]
// + headers:    [ 0,   i>0,  "a_string" ]
// + "Rite Aid": [ 0,   null, "Rite Aid" ]
//
// JSON.parse($0.textContent).map(i => [  i.categories.length, i.page_destination, i.name ] )

flyer_sections =
    JSON.
        parse($0.textContent).
        filter( item => item.categories.length).
        reduce( (acc, item) => {
            item.categories.forEach(
                category => {
                    acc[category] = acc[category] ? acc[category].concat(item) : [ item ]
                }
            );
            return acc;
        }, {});

Object.keys(flyer_sections).map( category => {

    products =
        flyer_sections[category].
        map( i => [ i.name, i.description, [ i.pre_price_text, i.price_text, i.post_price_text ].join(' '), i.disclaimer_text ].join('; ').
            replaceAll(/\n+/g, ' ')
        );

    return [ category ].concat(products);
});
```

<!-- }}- -->
## 1. Rite Aid API <!-- {{- -->

### 1.1 Store-related URLs <!-- {{- -->

The first gets information about a specific store, the second one lists stores close (on what criteria?) to ZIP.

> **Request URL**:
>
>                                                                                                          VVVVVVVVVV
>     https://dam.flippenterprise.net/flyerkit/store/riteaid?access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&store_code=6520
>                                                                                                          ^^^^^^^^^^
>
>                                                   V                                                       VVVVVVVVVVV
>     https://dam.flippenterprise.net/flyerkit/stores/riteaid?access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&postal_code=6520
>                                                   ^                                                       ^^^^^^^^^^^
>
> **Request Method**:
>
>     GET
>
> **Query parameters** (mandatory)
>
> + `store_code`: For querying individual stores (1st URL).
>
> + `postal_code`: To list stores "close" to a ZIP code (2nd URL).

---

**Return value**: JSON

---

None of this seems useful: when querying stores for ZIP "95811", there are 5 results, but only one is really open; the rest has been shut down over the years. (This one open stores is the only one that has flyers available on the website as well.)

<!-- }}- -->
### 1.2 Available flyers <!-- {{- -->

> **Request URL**:
>
>     https://dam.flippenterprise.net/flyerkit/publications/riteaid?locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&show_storefronts=true&postal_code=95811&store_code=6520
>
> **Request Method**:
>
>     GET
>
> **Query parameters**
>
> TODO: experiment which ones are needed. (Rite Aid is using the Flipp API so look into other Flipp-using stores - and, finally, create a document in the `flipp` directory noting the similarities and differences.)

---

**Return value**: JSON

---

<!-- }}- -->
### 1.3 Flyer data <!-- {{- -->

> **Request URL**:
>
>                                                           VVVVVVVV
>     https://dam.f/ippenterprise.net/flyerkit/publication/<flyer_id>/products?display_type=all&locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4
>                                                           ^^^^^^^^

>
> **Request Method**:
>
>     GET
>

---

**Return value**: JSON

---

`flyer_id` corresponds to `id` in the response of section 1.2 above.

<!-- }}- -->
### 1.4 Info on selected products <!-- {{- -->

> **Request URL**:
>
>     https://dam.flippenterprise.net/flyerkit/products?locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&product_ids=<product_ids>
>
> **Request Method**:
>
>     GET
>

---

**Return value**: JSON

---

Where `product_ids` are comma-delimited list of product IDs (without space) that are URL-encoded before submitting the request. For example: `product_ids=711651473%2C713179288%2C711651611%2C711651736`, where info on 3 products are requested. The IDs can be found in the response of section 1.3 above (`id` of each item).

> TODO: Product info in the response of 1.3 seems to be superior to the one in this request. Investigate if this is any useful.

---

<!-- }}- -->
<!-- }}- -->
## Historical notes <!-- {{- -->

### Flyer-related requests when reloading the [Rite Aid weekly ad page](https://www.riteaid.com/weekly-ad) <!-- {{- -->

* https://dam.flippenterprise.net/flyerkit/store/riteaid?access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&store_code=6520

  Response:

  {"id":54584,"name":"4830 J STREET","merchant_store_code":"6520","postal_code":"95819","province":"CA","city":"SACRAMENTO","address":"4830 J STREET","phone_number":"9164512187","latitude":"38.566539","longitude":"-121.443259","mon_open":null,"mon_close":null,"tue_open":null,"tue_close":null,"wed_open":null,"wed_close":null,"thu_open":null,"thu_close":null,"fri_open":null,"fri_close":null,"sat_open":null,"sat_close":null,"sun_open":null,"sun_close":null}

  > NOTE: Only the J street store seems to be active (but then again, the store doesn't matter; only that we have the ID of a still active one for the API calls)

<!-- }}- -->

<!-- }}- -->

vim: set foldmethod=marker foldmarker={{-,}}- foldlevelstart=0 tabstop=2 shiftwidth=2 expandtab:
