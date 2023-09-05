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

## Save script from Chrome console <!-- {{- -->

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
vim: set foldmethod=marker foldmarker={{-,}}- foldlevelstart=0 tabstop=2 shiftwidth=2 expandtab:

