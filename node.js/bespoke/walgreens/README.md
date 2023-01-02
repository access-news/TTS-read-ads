## 1. Walgreens API

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


vim: set tabstop=2 shiftwidth=2 expandtab:
