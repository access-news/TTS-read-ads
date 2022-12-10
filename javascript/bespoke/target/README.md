# Notes on the Target API

## 1. Find the store ID

### 1.1 Request

**Request URL**: `https://www.target.com/store-locator/find-stores/05403`
**Request Method**: `GET`

This will return an HTML page with a list of Target stores in the vicinity. For example, `https://www.target.com/store-locator/find-stores/95811`.

> NOTE
> Target's `https://www.target.com/store-locator/find-stores` page offers city and state names as search criteria as well, but if we ever need to use this, the ZIP will be more than enough.

The store ID can be listed by parsing the HTML response:

> NOTE
> It may be a bit more involved than that: when I looked at the response HTML on the "Network" tab in Chrome DevTools, the response and the rendered page were different... There are a lot of script tags in the response, so the stores are probably retrieved from the client side. The script below was applied to the rendered page.

    Array.
      from(document.getElementsByTagName("a")).
      filter( a => a.href.match(new RegExp("/sl/.*/[0-9]{4}")) ).
      map( a => a.href )

    /* Sample output:: */
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



vim: set tabstop=2 shiftwidth=2 expandtab:
