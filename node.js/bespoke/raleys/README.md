## 1. Raley's API

### 1.1 Flyer data

> **Request URL**:
>
>     https://shop.raleys.com/api/v2/flyer
>
> **Request Method**:
>
>     GET
>
> **Query parameters**
>
>     https://shop.raleys.com/api/v2/flyer?limit=60&offset=0&sort=position
>
> + `limit`: Allows for pagination
>
> + `offset`: Assists with pagination. Should be used together with `limit`.
>
> + `sort`: Supposed to sort the returned items, but don't know what other arguments besides `position` is accepted. The default is `sort=position`, so if the URL is called without any query parameters, the results will be sorted by how they appear on the website.

---

**Return value**: JSON

---

This only returns the items for the current flyer, without any metadata about the flyer itself (e.g., no dates of validity). The only metadate returned is the item count on the flyer.

### 1.2 Product categories

> **Request URL**:
>
>     https://shop.raleys.com/api/v2/categories
>
> **Request Method**:
>
>     GET
>
> **Query parameters**
>
>     https://shop.raleys.com/api/v2/categories?store_id=128
>
> + `store_id`: It seems to work without this (especially because the returned values seem to be chain-wide categories), but will need to test this.

---

**Return value**: JSON

---

This returned 700 hundred distinct categories with an array of brand names that belong to each category. This sounds useful, but didn't dig deep into the flyer data yet to see if it really is. Sounds cool nonetheless.

> NOTE 2023-01-02_1124
> After looking at the categories, this may be useless... There is a `Fresh Fruit` category with an icon showing apples, the brand names are all apples - and there is an `Apple` category with nonsense names.

### 1.3 Flyer PDF placements (?)

> **Request URL**:
>
>     https://shop.raleys.com/api/v2/placements/flyer_pdf
>
> **Request Method**:
>
>     GET
>

---

**Return value**: JSON

---

This seems to be completely useless as it (probably) returns information on how to embed the images of the flyers in PDF format into a WordPress template (making a lot of assumptions here), but there is a URL in the return JSON that could be useful:

    https://www.raleys.com/weekly-ad/

(The page listing all available flyers in PDF format.)

### 1.4 Store product facets (?)

> **Request URL**:
>
>     https://shop.raleys.com/api/v2/store_products/facets
>
> **Request Method**:
>
>     GET
>

---

**Return value**: JSON

---

This seems to showing product groups within where items are displayed on the website, but the `item_count` for all group is 0. Anyway, listing it here for completeness' sake.

### 1.5 Store locations

> **Request URL**:
>
>     https://shop.raleys.com/api/v2/stores
>
> **Request Method**:
>
>     GET
>

---

**Return value**: JSON

---

Shows all the Raley's stores.

vim: set tabstop=2 shiftwidth=2 expandtab:
