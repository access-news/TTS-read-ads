As far as I can tell, every single store (large or small, nationwide or local to a state, grocery or retail, etc.) puts out the same flyers everywhere regardless of geographic location. They websites won't show the ads until a ZIP code is given and a store is chosen, because this how the most basic customer statistics are collected.

## Chains using [flipp](https://corp.flipp.com/)

Couldn't find an public API description but one can find the right URL via Chrome's dev tools on the "Network" tab (TODO: insert methods from other browswers here).

### Safeway

#### 1. List available flyers (or "publications")

The URL we use to list available flyers (which usually means the weekly flyer and the Big Book of Savings) is this:

```
https://dam.flippenterprise.net/flyerkit/publications/safeway?locale=en&access_token=7749fa974b9869e8f57606ac9477decf&show_storefronts=true&postal_code=05403&store_code=3132
```

Even though only `locale`, `access_token` and `store_code` is needed:

```
https://dam.flippenterprise.net/flyerkit/publications/safeway?locale=en&access_token=7749fa974b9869e8f57606ac9477decf&store_code=654
```

The return value is an array of "publication" objects:

```
> JSON.parse($0.textContent)
 ▼ (2) [{…}, {…}]
   ▼ 0:
      available_from: "2022-01-25T00:00:00-05:00"
      available_to: "2022-02-01T23:59:59-05:00"
      correction_notices: []
      custom_flyer_item_disclaimer: ""
      deep_link: "https://coupons.safeway.com/weeklyad/?flyer_run_id=759561&flyer_type_name=weeklyad&locale=en&postal_code=94611&store_code=654"
      description: "N1ST"
      external_display_name: "Weekly Ad"
      first_page_thumbnail_150h_url: "https://f.wishabi.net/sub_pages/thumbnail/3d6335c6-788e-11ec-9545-0edc53c25ee6/thumbnail_image_150h_s3_key"
      first_page_thumbnail_400h_url: "https://f.wishabi.net/sub_pages/thumbnail/3d6335c6-788e-11ec-9545-0edc53c25ee6/thumbnail_image_400h_s3_key"
      first_page_thumbnail_2000h_url: "https://f.wishabi.net/sub_pages/thumbnail/3d6335c6-788e-11ec-9545-0edc53c25ee6/thumbnail_image_xlarge_s3_key"
      first_page_thumbnail_url: "https://f.wishabi.net/sub_pages/thumbnail/3d6335c6-788e-11ec-9545-0edc53c25ee6/thumbnail_image_xlarge_s3_key"
      flyer_run_id: 759561
      flyer_selector_thumbnail_url: "https://f.wishabi.net/flyers/4638078/thumbnail/1643040936.jpg"
      flyer_type: "weeklyad"
      flyer_type_id: 8209
      french_custom_flyer_item_disclaimer: ""
      id: 4638078
      image_first_page_100w: "https://f.wishabi.net/flyers/4638078/first_page_thumbnail_100w/1643040936.jpg"
      image_first_page_140w: "https://f.wishabi.net/flyers/4638078/first_page_thumbnail_140w/1643040936.jpg"
      image_first_page_400w: "https://f.wishabi.net/flyers/4638078/first_page_thumbnail_400w/1643040936.jpg"
      key_message: "Grocery Deals"
      key_message_short: "Grocery Deals"
      locale: "en"
      min_sfml_semantic_version: "1.0.0"
      min_sfml_version: 1
      name: "Weekly Ad - Safeway - NorCal"
      pdf_url: "https://f.wishabi.net/flyers/29329592/139b4fb9a9f79281.pdf"
      postal_code: "94611"
      sfml_url: "https://sfml.flippback.com/759561/4638078/06d1521d4779bfd0638d235ae82200dfa40a220545905a90f0d1dd4da625b9da.sfml"
      storefront_payload_url: "https://cdn-gateflipp.flippback.com/storefront-hosted/759561/4638078/06d1521d4779bfd0638d235ae82200dfa40a220545905a90f0d1dd4da625b9da?store_id=587657"
      thumbnail_image_url: "https://f.wishabi.net/flyers/4638078/l_thumbnail/1643040936.jpg"
      total_pages: 5
      valid_from: "2022-01-26T00:00:00-05:00"
      valid_to: "2022-02-01T23:59:59-05:00"
      validity_text: "Expires this Tuesday"
    ▶ [[Prototype]]: Object
  ▶ 1: {id: 4590447, flyer_run_id: 766467, flyer_type_id: 8209, name: 'Weekly Ad - Safeway - NorCal', description: 'N1ST', …}
    length: 2
  ▶ [[Prototype]]: Array(0)
```

#### 2. List items in a flyer

The general template is

```
https://dam.flippenterprise.net/flyerkit/publication/<publication_id>/products?display_type=all&locale=en&access_token=7749fa974b9869e8f57606ac9477decf
```

where `publication_id` is the `id` in the "publication" objects returned from in the previous section above, and the `access_token` is the same as there; it seems to be assigned to a chain. Getting the message below usually means that the `id` is not correct.

```
{"message":"Invalid publication_id or access_token","code":"422"}
```

##### 2.1 Examples

To get the weekly flyer:

```
https://dam.flippenterprise.net/flyerkit/publication/4638078/products?display_type=all&locale=en&access_token=7749fa974b9869e8f57606ac9477decf
```

To get the Big Book of Savings:

```
https://dam.flippenterprise.net/flyerkit/publication/4590447/products?display_type=all&locale=en&access_token=7749fa974b9869e8f57606ac9477decf
```

the returned JSON is an array with the flyer items, where each item is an object. The item ojbjects have a `coupon` property that is **always** empty, but these are instead reflected in the `categories` (array) and/or `disclaimer` (string) properties. In case of the latter, this manifests in the extra line in the `disclaimer` property, saying:

> Safeway for U™ coupon must be present at check out or downloaded to your account prior to purchase. LIMIT ONE Coupon per Household per Day. Expires 1/25/22.

---

To check

    f.map(function(item) { return { "categories": item.categories.sort().join('|'), "disclaimer": item.disclaimer, "couponsArray": item.coupons }; })

where `f` is the JSON from link 1. or 2. (i.e., URLs 1. and 2. have the exact same structure, and just wanted to give extra examples)
