  defmodule Ads.Safeway.Product do

    # NOTE 2022_05_30T1201
    # Split up `categories` array/list to `category` string and `coupon` boolean; the original `categories` array/list usually only has 1 element, a category in the flyer, except when the product also has a corresponding coupon, then it is `[ <category>, "Coupon"]`. (There is a `coupons` key that is always an empty list, go figure. Also, `deal`s - nee `sale_story` - rarely coincide with coupons so don't think much into it.)
    @enforce_keys \
      ~w( category
          coupon
          current_price
          description
          disclaimer
          dollars_off
          id
          name
          on_page
          post_price_text
          pre_price_text
          price_text
          deal
        )a
        # TODO typespecs

    defstruct @enforce_keys
  end

