  defmodule Ads.Safeway.Flyer do

    @enforce_keys \
      ~w( id
          products
          name
          page_total
          valid_from
          valid_to
        )a

    defstruct @enforce_keys
  end
