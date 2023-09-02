## 1. Rite Aid API

### 1.1 Store-related URLs

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

### 1.2 Available flyers

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

### 1.3 Flyer data

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

### 1.4 Info on selected products

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

## Historical notes

### Flyer-related requests when reloading the [Rite Aid weekly ad page](https://www.riteaid.com/weekly-ad)

* https://dam.flippenterprise.net/flyerkit/store/riteaid?access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&store_code=6520

  Response:

  {"id":54584,"name":"4830 J STREET","merchant_store_code":"6520","postal_code":"95819","province":"CA","city":"SACRAMENTO","address":"4830 J STREET","phone_number":"9164512187","latitude":"38.566539","longitude":"-121.443259","mon_open":null,"mon_close":null,"tue_open":null,"tue_close":null,"wed_open":null,"wed_close":null,"thu_open":null,"thu_close":null,"fri_open":null,"fri_close":null,"sat_open":null,"sat_close":null,"sun_open":null,"sun_close":null}

  > NOTE: Only the J street store seems to be active (but then again, the store doesn't matter; only that we have the ID of a still active one for the API calls)

vim: set foldmethod=marker foldmarker={{-,}}- foldlevelstart=0 tabstop=2 shiftwidth=2 expandtab:
