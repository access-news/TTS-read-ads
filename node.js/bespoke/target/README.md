## 1. Node.js notes

### Step 0. Install NPM packages for this project (if needed)

When in a new clone of this repo, do this first:

    npm install

### Step 1. Edit [`index.js`](./index.jd)

If this project is still in the early stages, the very end of [`index.js`](./index.jd) may not call the Azure Speech SDK but is set to output the parsed flyer text to `stdout`, so check this first.

### Step 2. Run `node index.js`

... but prepend it with the required environment variables first like this:

    SPEECH_REGION="<azure_region>" SPEECH_KEY="<speech_service_key_from_azure_portal>" node index.js

## 2. Notes on the Target API

The `key` parameter in the API URLs below seems to be constant, but will keep an eye out.

### 2.1 Store locations

#### 2.1.1 Find a store ID (i.e., `location_id`)

> **Request URL**:
>
>     https://www.target.com/store-locator/find-stores/<ZIP>
>
> **Request Method**:
>
>     GET

This will return an HTML page with a list of Target stores in the vicinity. For example, `https://www.target.com/store-locator/find-stores/95811`.

> NOTE
> Target's `https://www.target.com/store-locator/find-stores` page offers city and state names as search criteria as well, but if we ever need to use this, the ZIP will be more than enough.

The store ID (`location_id`; see next sections) can be listed by parsing the HTML response:

> NOTE
> It may be a bit more involved than that: when I looked at the response HTML on the "Network" tab in Chrome DevTools, the response and the rendered page were different... There are a lot of script tags in the response, so the stores are probably retrieved from the client side. The script below was applied to the rendered page.

    Array.
      from(document.getElementsByTagName("a")).
      filter( a => a.href.match(new RegExp("/sl/.*/[0-9]{4}")) ).
      map( a => a.href )

    /* Sample output: */
    [
        "https://www.target.com/sl/minneapolis-ne/1095",
        "https://www.target.com/sl/minneapolis-ne/1095",
        "https://www.target.com/sl/minneapolis-dinkytown/3200",
        "https://www.target.com/sl/minneapolis-dinkytown/3200",
        "https://www.target.com/sl/mpls-nicollet-mall/1375",
        "https://www.target.com/sl/mpls-nicollet-mall/1375",
        "https://www.target.com/sl/roseville-t1/2101",
        "https://www.target.com/sl/roseville-t1/2101",
        "https://www.target.com/sl/mpls-uptown-w-lake-st-fremont-ave/3239",
        "https://www.target.com/sl/mpls-uptown-w-lake-st-fremont-ave/3239",
        "https://www.target.com/sl/fridley/2200",
        "https://www.target.com/sl/fridley/2200",
        "https://www.target.com/sl/st-paul-midway/2229",
        "https://www.target.com/sl/st-paul-midway/2229",
        "https://www.target.com/sl/st-paul-highland-park/3204",
        "https://www.target.com/sl/st-paul-highland-park/3204",
        "https://www.target.com/sl/richfield/2300",
        "https://www.target.com/sl/richfield/2300",
        "https://www.target.com/sl/knollwood-hwy-7/2189",
        "https://www.target.com/sl/knollwood-hwy-7/2189",
        "https://www.target.com/sl/edina/2313",
        "https://www.target.com/sl/edina/2313"
    ]

Interestingly, the city names do not matter; store 3306 is in Vermont, but if 1095 in `https://www.target.com/sl/minneapolis-ne/1095` is simply replaced by 3306, the Vermont store will come up.

#### 2.1.2 Get info on a single store

> **Request URL**:
>
>     https://api.target.com/locations/v3/public/<LOCATION_ID>?key=9ba599525edd204c560a2182ae1cbfaa3eeddca5
>
> **Request Method**:
>
>     GET

---

**Return value**: object

---

> NOTE
> 1. `LOCATION_ID` is the unique store ID.
> 2. The difference between the request URL above and in the next section (i.e., 1.3) is that the latter doesn't need the `LOCATION_ID`, only the query params.

See [this sample output](https://gist.github.com/toraritte/f83daceda83b06ffc3fe6b36e13bd36a) for the Target in Sacramento, CA on Riverside Blvd. (`location_id` 310).

#### 2.1.3 List store locations with all the public information

> **Request URL**:
>
>     https://api.target.com/locations/v3/public/?key=9ba599525edd204c560a2182ae1cbfaa3eeddca5
>
> **Request Method**:
>
>     GET
>
> **Available<sup><b>†</b></sup> parameters**:
>
> <sup><b>†</b> That is, ones that are currently figured out as the Target API docs are not publicly available (I couldn't find them yet, at least).</sup>
>
> + `per_page`
>
>    Number of Target locations retrieved in one request. **Default**: 10, if not present.
>
> + `page`
>
>    If the `per_page` parameter is less than the total number of Target stores then the next `per_page` amount can be retrieved by incrementing the `page` number.

> NOTE [`link` HTTP entity-headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Link) are returned with the responses, supporting [link types](https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types) `prev`, `first`, `next`, `last`.

---

**Return value**: object

---

> NOTE There are ca. 2500 Target locations.

**Examples**:

    https://api.target.com/locations/v3/public/?key=9ba599525edd204c560a2182ae1cbfaa3eeddca5

Will return the first 10 stores (sorted by `location_id`), and

    https://api.target.com/locations/v3/public/?key=9ba599525edd204c560a2182ae1cbfaa3eeddca5&page=2

will return the next 10.

    https://api.target.com/locations/v3/public/?key=9ba599525edd204c560a2182ae1cbfaa3eeddca5&per_page=100&page=2

Returns the stores 101-200 (again, sorted by `location_id`).

### 2.2 Available flyers

> Request URL:
>
>     https://api.target.com/weekly_ads/v1/store_promotions?key=9ba599525edd204c560a2182ae1cbfaa3eeddca5&store_id=<LOCATION_ID>
>
> Request Method:
>
>     GET

> NOTE
> `LOCATION_ID` is the unique store ID.

Sample response:

    [
        {
            "store_id": "3306",
            "promotion_id": "3306-20221204",
            "code": "Target-20221204",
            "title": "Weekly Ad",
            "promotion_start_date": "12/02/2022 12:00:00 AM",
            "promotion_end_date": "12/10/2022 11:59:00 PM",
            "sale_start_date": "12/04/2022 12:00:00 AM",
            "sale_end_date": "12/10/2022 11:59:00 PM",
            "days_to_save": 1,
            "display_order": 1,
            "cover_image": "https://target.scene7.com/is/image/Target/20221204_01mw_mzF1c?wid=750",
            "scrubbed_cover_image": "",
            "sneak_peek": false,
            "dwa_search": false,
            "catalog": false,
            "promotion_type": "weeklyad"
        },
        {
            "store_id": "3306",
            "promotion_id": "3306-20221211",
            "code": "Target-20221211",
            "title": "Sneak Peek",
            "promotion_start_date": "12/09/2022 12:00:00 AM",
            "promotion_end_date": "12/17/2022 11:59:00 PM",
            "sale_start_date": "12/11/2022 12:00:00 AM",
            "sale_end_date": "12/17/2022 11:59:00 PM",
            "days_until_sale": 1,
            "display_order": 1,
            "cover_image": "https://target.scene7.com/is/image/Target/20221211_01al_3kUUx?wid=750",
            "scrubbed_cover_image": "",
            "sneak_peek": true,
            "dwa_search": false,
            "catalog": false,
            "promotion_type": "weeklyad"
        }
    ]

### 2.3 Flyer data

> **Request URL**:
>
>     https://api.target.com/weekly_ads/v1/promotions/<PROMOTION_ID>?key=9ba599525edd204c560a2182ae1cbfaa3eeddca5
>
> **Request Method**:
>
>     GET

---

**Return value**: object

---

vim: set tabstop=2 shiftwidth=2 expandtab:
