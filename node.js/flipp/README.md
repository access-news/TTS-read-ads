As far as I can tell, every single store (large or small, nationwide or local to a state, grocery or retail, etc.) puts out the same flyers everywhere, regardless of geographic location. Which is weird, given that most of the sites won't show the ads until a ZIP code is given and/or a store is chosen. (I presume this done to collect user statistics?)

## Chains using [flipp](https://corp.flipp.com/) <!-- {{- -->

+ Safeway
+ Rite Aid

See [Safeway's README](./safeway/README.md) for more.

<!-- }}- -->
## Flipp REST API notes <!-- {{- -->

Couldn't find an public REST API description, but one can
find the URLs  of the REST API via Chrome's  dev tools on
the "Network"  tab in Chrome.

> TODO: insert methods for other browsers here.

### List available flyers of a retail company's store <!-- {{- -->

A flyer in Flipp lingo is called a "publications".

    https://dam.flippenterprise.net/flyerkit/publications/safeway?locale=en&access_token=7749fa974b9869e8f57606ac9477decf&show_storefronts=true&postal_code=05403&store_code=3132
    https://dam.flippenterprise.net/flyerkit/publications/riteaid?locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&show_storefronts=true&postal_code=95811&store_code=6520

After some experimentation, the only **required** URL parameters seem to be the following:

+ `locale`
+ `access_token`
+ `store_code`

This is a valid Flipp REST API request:

    https://dam.flippenterprise.net/flyerkit/publications/safeway?locale=en&access_token=7749fa974b9869e8f57606ac9477decf&store_code=654

#### Generalized form

                                                          VVVVVVVVVVVVVVVVVVVVV                        VVVVVVVVVVVVVVVVVVV            VVVVVVVVVVVV
    https://dam.flippenterprise.net/flyerkit/publications/<retail_company_name>?locale=en&access_token=<retail_company_id>&store_code=<store_code>
                                                          ^^^^^^^^^^^^^^^^^^^^^                        ^^^^^^^^^^^^^^^^^^^            ^^^^^^^^^^^^

  <!-- }}- -->
### List all products in a flyer <!-- {{- -->

For Flipp REST API, the only thing that matters is the `access_token` when it comes to **listing all the products in a flyer**: The first 2 is for a Safeway flyer, and the last one is for Rite Aid.

    https://dam.flippenterprise.net/flyerkit/publication/4638078/products?display_type=all&                    locale=en&access_token=7749fa974b9869e8f57606ac9477decf
    https://dam.flippenterprise.net/flyerkit/publication/4590447/products?display_type=all&                    locale=en&access_token=7749fa974b9869e8f57606ac9477decf
    https://dam.flippenterprise.net/flyerkit/publication/5801937/products?display_type=all&valid_web_url=false&locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4

#### Generalized form

                                                          VVVVVVVVVVVVVVVV                                                  VVVVVVVVVVVVVVVVVVV
    https://dam.flippenterprise.net/flyerkit/publication/<publication_id>/products?display_type=all&locale=en&access_token=<retail_company_id>
                                                          ^^^^^^^^^^^^^^^^                                                  ^^^^^^^^^^^^^^^^^^^

  <!-- }}- -->
### List one specific product <!-- {{- -->

    https://dam.flippenterprise.net/flyerkit/product/761645407?locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4
    
#### Generalized form

                                                     VVVVVVVVVVVV                        VVVVVVVVVVVVVVVVVVV
    https://dam.flippenterprise.net/flyerkit/product/<product_id>?locale=en&access_token=<retail_company_id>
                                                     ^^^^^^^^^^^^                        ^^^^^^^^^^^^^^^^^^^

`product_id` is the same as `id` in the list of products when listing all products in a flyer.

  <!-- }}- -->
### List arbitrary number of products <!-- {{- -->

    https://dam.flippenterprise.net/flyerkit/products?locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&product_ids=761638105%2C761638161%2C761605207%2C761638014

https://dam.flippenterprise.net/flyerkit/store/riteaid?locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&store_code=6520
https://dam.flippenterprise.net/flyerkit/stores/riteaid?locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&postal_code=95811

#### Generalized form

                                                                             VVVVVVVVVVVVVVVVVVV             VVVVVVVVVVVV   VVVVVVVVVVVV         VVVVVVVVVVVV
    https://dam.flippenterprise.net/flyerkit/products?locale=en&access_token=<retail_company_id>&product_ids=<product_id>%2C<product_id>%2C...%2C<product_id>
                                                                             ^^^^^^^^^^^^^^^^^^^             ^^^^^^^^^^^^   ^^^^^^^^^^^^         ^^^^^^^^^^^^

`product_id` is the same as `id` in the list of products when listing all products in a flyer.

  <!-- }}- -->
### List one specific store <!-- {{- -->

    https://dam.flippenterprise.net/flyerkit/store/riteaid?locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&store_code=6520

#### Generalized form

                                                                                  VVVVVVVVVVVVVVVVVVV            VVVVVVVVVVVV
    https://dam.flippenterprise.net/flyerkit/store/riteaid?locale=en&access_token=<retail_company_id>&store_code=<store_code>
                                                                                  ^^^^^^^^^^^^^^^^^^^            ^^^^^^^^^^^^

  <!-- }}- -->
### List all stores in the vicinity of a US postal code <!-- {{- -->

    https://dam.flippenterprise.net/flyerkit/stores/riteaid?locale=en&access_token=0ebf9efc5d4c2b8bed77ca26a01261f4&postal_code=95811

#### Generalized form

                                                                                   VVVVVVVVVVVVVVVVVVV             VVVVVVVVVVVVVVVV
    https://dam.flippenterprise.net/flyerkit/stores/riteaid?locale=en&access_token=<retail_company_id>&postal_code=<us_postal_code>
                                                                                   ^^^^^^^^^^^^^^^^^^^             ^^^^^^^^^^^^^^^^

  <!-- }}- -->
<!-- }}- -->
## IDs <!-- {{- -->

### `retail_company_name`s <!-- {{- -->

+ `safeway`
+ `riteaid`

  <!-- }}- -->
### `retail_company_id`s <!-- {{- -->

+ 7749fa974b9869e8f57606ac9477decf (safeway)
+ 0ebf9efc5d4c2b8bed77ca26a01261f4 (rite aid)

  <!-- }}- -->
<!-- }}- -->

<!-- vim: set foldmethod=marker foldmarker={{-,}}- foldlevelstart=0 tabstop=2 shiftwidth=2 expandtab: -->
