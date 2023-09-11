## 0. Interim solution <!-- {{- -->

The real solution (I think) lies in section "1. Walgreens API" below, but until I have time to properly explore it, here's an ad hoc one:

1. Go to the [Walgreens weekly ad page](https://www.walgreens.com/offers/offers.jsp/weeklyad?view=weeklyad).

2. The page is not loaded all at once, so scroll down to the bottom.

   To check, go to the JavaScript console and call:

   ```javascript
   document.querySelector('#dwa_container > div.div-multipage-container')
   ```

   If the page is fully loaded, the only child elements without any children should be the `<div class="page-break"></div>` elements.

3. To flatten the `div` soup, use this, that will list every item with titles in the right places, so the whole page can be processed like a list:

   ```javascript
   document.querySelectorAll('.card-container, .jq-circ-page-header')
   ```

---

```javascript
const pick = (obj, needed_keys) => needed_keys.filter(key => key in obj).reduce((obj2, key) => (obj2[key] = obj[key], obj2), {});

items = Array.from(document.querySelectorAll('.card-container, .jq-circ-page-header, .onlyImage img'));

reduced_items = r = items.map( htmlDivElement => ['ariaLabel', 'innerText', 'outerText', 'alt', 'classList', 'nodeName'].reduce( (acc, curr) => { acc[curr] = htmlDivElement[curr]; return acc; }, {}))

/*
r2 = r.map( i => {
    if (i.ariaLabel) {
        i.ariaLabel = i.ariaLabel.replace(/product /, '');
        i.innerText = i.innerText.replace(i.ariaLabel, '').replaceAll(/\n+/g, '. ');
    }; return i; })

r3 = r2.map( i => i.ariaLabel + '. ' + i.innerText )
*/

let gogo = (reduced_item) => {
    ri = reduced_item;

    if (ri.classList.contains('card-container')) {
        ri.ariaLabel = ri.ariaLabel.replace(/product /, '');
        ri.newInnerText =
            ri.innerText.
            /* Some info is in `ariaLabel` and some is in `innerText`,
               which is why their combination is needed (see below),
               but sometimes the `ariaLabel` string is contained in
               `innerText` in its entirety. `trim()` is needed because
               some `ariaLabel`s have extra whitespace at the ends.
            */
            replace(ri.ariaLabel.trim(), '').
            replaceAll(/\.+\s+/g, '; ');

        ri['proposed_text'] = (ri.ariaLabel + '; ' + ri.newInnerText).
            replaceAll(/\n+/g, '; ').
            replaceAll(/Shop now\.?/g, '').
            replaceAll(/Shop products/g, '').
            replaceAll(/[†Ω∞®‡»®*◊™]/g, '').
            replaceAll(/(\d)\//g, "$1 for ").
            replaceAll(/\sct\./g, '-count').
            replaceAll(/\sin\./g, '-inch').
            replaceAll(/\soz\./g, '-ounce').
            replaceAll(/\ml\./g, ' milliliter').
            replaceAll(/BOGO/g, 'Buy one get one').
            replaceAll(/(\d+)\s(\d+)/g, "$1.$2").
            replaceAll(/[;.]\s+(or|with|when)/g, " $1").
            replaceAll(/(online coupon)/ig, 'with $1').
            /* check for consecutive semicolons (interspersed with whitespace)
               rg.filter( e => typeof e.match === 'function').filter( e => e.match(/;\s+;/i))
            */
            replaceAll(/(;\s)+/g, '; ').
            /* check for lines NOT ending with dots
               rg.filter( e => typeof e.match === 'function').filter( e => !e.match(/\.$/))
            */
            replace(/;(\s?)+$/, '.').
            replace(/([^.])$/, '$1.').
            /* The decimal point is missing at many places (thus creating ridiculous prices),
               this query should show that every number larger than 3 digits that represents
               a price should be preceded by a dollar sign.
               rg.filter( e => typeof e.match === 'function').filter( e => e.match(/\d{3,}/)).map(e => e.match(/(...\d{3,}...)/g));
            */
            replaceAll(/\$(\d+)(\d\d)/g, '$$$1.$2');
    } else if (ri.classList.contains('jq-circ-page-header')) {
        /* This class is usually for elements that contain section headers. */
        ri['title'] = ri.innerText;
    } else if (ri.nodeName === 'IMG') {
        /* Last week, there was ONE image that was basically a header, but it didn't have the `jq-circ-page-header`. It happened this week as well, so hoping that this is a recurring theme. */
        ri['title'] = ri.alt;
    } else {
        /* Catch-all clause for items not handled above. */
        console.log(ri);
    }

    return ri;
}

rg = r.map(gogo).
    map( i => {
        if (i.proposed_text) {
            if        (i.proposed_text.match(/^DI:/)) {
                return "";
            } else if (i.proposed_text.match(/online exclusives/i)) {
                return "";
            } else if (i.proposed_text.match(/(coupon hub|start clipping|DOTW)/)) {
                return "";
            } else {
                return i.proposed_text;
            }
        } else {
            return i;
        }
    });

/* For 2 weeks now, the organization of the ads were:
   some initial ads without any header, followed by an
   `<img>` tag stating "Deals of the Week". So adding
   the first couple of products to it as well.

                           return the index of the first
                           item that has a title property
                           VVVVVVVVVVVVVVVVVVVVVVVVVVV
*/
dealsOfTheWeekHeader = rg.splice(rg.findIndex( i => i.title), 1)[0];
/*                                                            ^
                                                    remove that one item
*/
dealsOfTheWeekHeader.title = dealsOfTheWeekHeader.title.replace('Header.', '').trim();
rg.unshift(dealsOfTheWeekHeader);

/* partition the page item flow array (rg)
   into [ [title, ...items], [title, ...items], ...]
*/
cats =
    rg.reduce(
        (acc, item) => {
            if (item.title) {
                /*                       Add dot if none. */
                acc.unshift( [item.title.replace(/\.?\s?$/, '.')] );
            } else {
                acc[0].push(  item  );
            }
            return acc;
        },
        []
    ).
    reverse();

copy(cats.map( c => c.join(' ') ).join(' End of category.\n') + " End of flyer.")
```

<!-- }}- -->
## 1. Walgreens API <!-- {{- -->

> WARNING
> These HTTP requests are using `POST`!

Load the `.har` file in an analyzer tool (e.g., Google's [`har_analyzer`](https://toolbox.googleapps.com/apps/har_analyzer/)) to know more of the API calls. Walgreens' API is a bit more involved than the others as most requests use the `POST` method, so will have to decipher what the proper request body is. Details below.

### 1.1 "Circular" data

> **Request URL**:     `https://wag-dwa-api-prod.przone.net//api/wag/dwa/circular`
> **Request Method**:  `POST`
> **Status Code**:     `200 `
> **Remote Address**:  `[2600:1401:6000::b81a:292b]:443`
> **Referrer Policy**: `strict-origin-when-cross-origin`

---

**Return value**: JSON

---

#### 1.1.1 Response

Not sure for the exact purpose for this, and it seems as if this had been forgotten (or no one cares about making it right). For example:

+ **`weeklyAds` attribute**: shows 4 items - 1 for the current flyer, and 3 outdated ones (the newest one is still outdated by half a year)

+ **`pages` attribute**: the previous attribute also doesn't make sense, because this one lists the pages of the currently active flyer (with unique IDs). The only useful info in the individual pages (apart from the IDs) is the `name` attribute, that seems to denote the category of the items on a page.

QUESTION: Why not list the items with the pages? I presume that these will have to be requested individually with the IDs...

ANSWER: Yes, `collectionId`s are needed to request the pages individually; see next section.

#### 1.1.2 Request body

Load the `.har` file in this directory to take a look, but it seems straightforward (well, we'll see upon trying it from Node) - except for one: the `user.affinityOffers` attribute. This is a 60+ long array with weird codes. Will the request go through without this?

> TODO: Try out sending a `POST`  request **without** the `affinityOffers` (or with it being an empty array, that is).

> NOTE: `affinityOfferId` in `<request-body>.user.affinityOffers` is the exact same format as `uniqueId` in a requested flyer page's item. (`<page_number>.offers[i].uniqueId`). An item / product is called an "offer" in Walgreens parlance.


### 1.2 "Circular page" data

That is, returns "offers" (=> item / product) on a specific page of a flyer.

> **Request URL**:     `https://wag-dwa-api-prod.przone.net//api/wag/dwa/collection?collectionid=fe9bbb58-8eec-46f1-b989-6acac33fa4c1&store=1852`
> **Request Method**:  `POST`
> **Status Code**:     `200 `
> **Remote Address**:  `[2600:1401:6000::b81a:292b]:443`
> **Referrer Policy**: `strict-origin-when-cross-origin`

---

**Return value**: JSON

---

The `collectionid` query parameter in the API URL corresponds to `collectionId` described in "**1.1.1 Response**" above. See note in "**1.1.2 Request body**" about an "offer"'s `uniqueId`.

### 1.3 Summary of a flyer page

> **Request URL**:     `https://wag-dwa-api-prod.przone.net//api/wag/dwa/circular/page?pageid=80d0ebbb-c4f2-4f7a-8027-36cfb158bb40`
> **Request Method**:  `POST`
> **Status Code**:     `200 `
> **Remote Address**:  `[2600:1401:6000::b81a:292b]:443`
> **Referrer Policy**: `strict-origin-when-cross-origin`

---

**Return value**: JSON

---

The `pageid` query parameter in the API URL corresponds to `circularPageId` returned in "**1.1.1 Response**" above.

Not sure if this is useful: The response contains the number of items in the page (this can be calculated simply from the array in the "circular page" JSON (section 1.2 above)), but also seems to show references from this page to other pages ("collections") via `<page-summary>.configuration.subCollections[i].id` (corresponding to a `collectionId` in "**1.1.1 Response**").

<!-- }}- -->
vim: set foldmethod=marker foldmarker={{-,}}- foldlevelstart=0 tabstop=2 shiftwidth=2 expandtab:
