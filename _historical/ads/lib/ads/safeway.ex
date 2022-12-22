defmodule Ads.Safeway do

  @moduledoc """
  TODO/QUESTION 2022-05-25T1810
  This  started  out  as   `GenServer`  but  left  the
  `init/1`  because this  is basically  initializing a
  connection  to the  Safeway ads  URL and  it may  be
  useful when returning to a behaviour laer on.

  WHY MOVE ON FROM GenServer?

  Because this is not  really a process but sequential
  execution of  code with a `receive`  loop (i.e., get
  the Safeway  flyers, then their contents,  etc.). It
  seems more  appropriate to write this  as sequential
  code  that could  be made  concurrent using  `Task`s
  later (or even GenStage, Flow, Broadway if splitting
  to stages  makes sense). If the  store chain modules
  would  all be  `GenServer`s  then  those would  have
  to  started  according  to  a  schedule,  and  right
  now  it  seems  easier to  use  `Task.async/3`  with
  `:max_concurrency`.

  NOTE/QUESTION 2022-05-25T1817
  Would `GenServer`/`GenStage`&co. make sense later on
  when  a common  pattern has  been identified  and to
  start it as workers with specific args from a pool?

  => ANSWER 2022-05-25T1849
     I   remember   now:   this   may  need   to   be   a
     process    because   `Mint.request/3`    is   async,
     and   piping  the   returned   `conn`  struct   into
     `Ads.collect_responses/1`  may  not yield  anything:
     its `receive` loop  immediately starts going through
     the  process' message  box, perhaps  concluding with
     `[]`  if  the  timeout  in  the  `after`  clause  is
     not  enough. With  a  `GenServer`  this wouldn't  be
     an  issue  as after  `init/1`,  when  there are  any
     incoming  messages, `handle_info/?`  will take  over
     automatically,  making sure  that  all the  messages
     will be  handled, always. (The timeout  may still be
     an  issue, because  these `GenServer`s  shouldn't be
     long running processes, but  then what should be the
     timeout? ->  Idiot, just terminate the  process once
     done with the appropriate tuple...)

  """

  def get_flyers do

    domain  = data().domain
    path    = data().url_path_fns.flyer_list.()
    headers = data().flipp_HTTP_headers

    # Safeway  usually has  2 active  flyers at  any
    # given time: the weekly ads and Big Book of Savings.
    { conn, flyer_jsons } =
      Ads.fetch_json(
        domain,
        path,
        headers
      )

    # IO.inspect(flyer_jsons)

    flyer_jsons
    |> Enum.map(&to_struct/1) #=> [ %.Flyer{ products: nil } ]
    |> Enum.reduce(
          { conn, [] },
          fn(flyer, {conn, out_list}) ->
            flyer                         #=> %Flyer{ products: nil }
            |> fetch_flyer()          #=> flyer_product_list_jsons === [ %{} ]
            |> Enum.map(&(to_struct(&1)))        #=> [ %Product{} ]
            |> (&( %{flyer | products: &1} )).() #=> %Flyer{ products: [%.Product{} ] }
            |> (&(  {conn, [&1|out_list]}  )).()
          end
          )
    |> elem(1) #=> [ %.Flyer{} ]
  end

  @doc """
  NOTE 2022_05_31T2036 DITCHING `CONN`
  The  second  flyer will  never  get  fetched as  the
  connection gets closed so  falling back to opening a
  new connection each time. Probably not understanding
  something about HTTP(S) and/or Mint
  """
  defp fetch_flyer(%__MODULE__.Flyer{} = flyer) do

    path =
      flyer.id
      |> data().url_path_fns.flyer.()

    headers =
      data().flipp_HTTP_headers

    { _conn, flyer_product_list_jsons } =
      Ads.fetch_json(
        data().domain,
        path,
        headers
      )

    # Ignoring `conn` on purpose as it shouldn't be needed
    # from this point on
    flyer_product_list_jsons

    # { conn \
    # , [
    #     Map.put_new(flyer_json, :items, flyer_product_json_list)
    #   | out_list
    #   ]
    # }
  end

  @doc """
  TODO 2022_05_23T1245 GENERALIZE
  1. There are other chains that use flipp so this can be
     refactored further
  2. This is  configuration so  figure out what  would be
     the  best way  to  store it  (as  config, it  should
     definitely be  an external input and  not hard-coded
     here

  TODO 2022_05_25T1936
  A recursive  data structure  (like in Nix)  would be
  nice here to  make the `flipp_access_token` template
  below less error prone  (i.e., renaming the function
  will break the URL). What would be the best solution
  here? Elixir has a templating lib, look into it.
  -> Some ideas:
     https://stackoverflow.com/questions/47281111/is-there-an-equivalent-to-module-for-named-functions-in-elixir-erlang
     https://stackoverflow.com/questions/36679379/elixir-call-method-on-module-by-string-name
     https://stackoverflow.com/questions/49360006/convert-module-name-to-string-and-back-to-module
  """
  def data do
    function_name = __ENV__.function |> elem(0)
    this_function = fn() -> apply(__MODULE__, function_name, []) end

    %{ domain: "dam.flippenterprise.net",
       flipp_access_token: "7749fa974b9869e8f57606ac9477decf",
       url_path_fns:
         %{ flyer_list: fn() -> "/flyerkit/publications/safeway?locale=en&access_token=#{this_function.().flipp_access_token}&store_code=654" end,
           flyer: fn(id) -> "/flyerkit/publication/#{id}/products?display_type=all&locale=en&access_token=#{this_function.().flipp_access_token}" end,
         },
       flipp_HTTP_headers: [{"accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"}, {"accept-encoding", "gzip, deflate, br"}, {"accept-language", "en-US,en;q=0.9,hu;q=0.8"}, {"cache-control", "no-cache"}, {"cookie", "_flyers_session=eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCMGtpRDNObGMzTnBiMjVmYVdRR09nWkZWRWtpSlRZeU5URTRNRGd6WTJNek9UZ3dOemM0TURobE5UWmhNemMyTkdSalpHWmtCanNBVkVraURYUmxjM1JmZG1GeUJqc0FSa2tpQm1ZR093QlUiLCJleHAiOiIyMDIyLTA4LTA1VDIxOjE5OjI2LjExMFoiLCJwdXIiOm51bGx9fQ%3D%3D--7d4183d3ddee74ad72b80114982d5dd8a3187ee5"}, {"pragma", "no-cache"}, {"sec-ch-ua", "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"101\", \"Google Chrome\";v=\"101\""}, {"sec-ch-ua-mobile", "?0"}, {"sec-ch-ua-platform", "\"Linux\""}, {"sec-fetch-dest", "document"}, {"sec-fetch-mode", "navigate"}, {"sec-fetch-site", "none"}, {"sec-fetch-user", "?1"}, {"upgrade-insecure-requests", "1"}, {"user-agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36"}]
    }
  end

  @doc """
  NOTE 2022_05_30T1910 REASONS FOR USING STRUCTS
  The  flipp-given JSON  keys may  change, so  if they
  do,  they  only need  to  be  changed here  and  not
  27  times down  the  line  (e.g., "key_message"  and
  "key_message_short" hold  exactly the same  value as
  "external_display_name"so not sure  which one is the
  canonical key to hold the name of the flyer)
  
  Also, the keys are now atoms and not strings

  TODO 2022_06_03T0745 HOW TO MAKE THIS MORE ROBUST?
  flipp might change up the JSON format any time...

  TODO 2022_06_03T0747 GENERALIZE
  The clauses  look very similar  so if there  will be
  more structs added, the  main structure could be put
  in a helper function.
  See also 2022_05_23T1245
  """
  defp to_struct(%{ "flyer_type" => _, "total_pages" => _ } = flyer_json) do

    keys_needed =
      ~w( id
          external_display_name
          total_pages
          valid_from
          valid_to
        )

    flyer_json
    |> Map.take(keys_needed)
    |> (fn(map) ->
         %__MODULE__.Flyer{
             id:         map["id"]                                   \
           , products:   nil                                         \
           , name:       map["external_display_name"]                \
           , page_total: map["total_pages"]                          \
           , valid_from: Timex.parse!(map["valid_from"], "{ISO:Extended}") \
           , valid_to:   Timex.parse!(map["valid_to"], "{ISO:Extended}")
         }
       end).()
  end

  defp to_struct(%{ "categories" => _, "page" => _ } = product_json) do

    keys_needed =
      ~w( categories
          current_price
          description
          disclaimer
          dollars_off
          id
          name
          original_price
          page
          post_price_text
          pre_price_text
          price_text
          sale_story
        )

    # NOTE 2022_05_31T1939 regarding `List.first(nil)` below:
    # (1) ["Coupon"]
    #   Some  product  JSONs  with  `categories`  keys  that
    #   contain  only  ["Coupon"]  so  `List.first/2`  would
    #   raise on getting an empty list, hence the default of
    #   `nil`. Coupons would be presented to listeners first
    #   anyway, so an empty category is not a big deal.
    # (2) []
    #   These   are   pure  marketing   "products"   (mostly
    #   promoting the chain itself,  etc.) so these could be
    #   filtered  out, but  it  feels cleaner  to have  them
    #   processed here  as well  and have them  removed down
    #   the line.

    product_json
    |> Map.take(keys_needed)
    |> (fn(map) ->
        # IO.inspect(map)
         %__MODULE__.Product{
             category: map["categories"]                  \
                       |> Enum.reject(&(&1 === "Coupon")) \
                       |> List.first(nil)                 \
           , coupon: map["categories"]                    \
                     |> Enum.member?("Coupon")            \
           , current_price:   map["current_price"]        \
           , description:     map["description"]          \
           , disclaimer:      map["disclaimer"]           \
           , dollars_off:     map["dollars_off"]          \
           , id:              map["id"]                   \
           , name:            map["name"]                 \
           , on_page:         map["page"]                 \
           , original_price:  map["original_price"]       \
           , post_price_text: map["post_price_text"]      \
           , pre_price_text:  map["pre_price_text"]       \
           , price_text:      map["price_text"]           \
           , deal:            map["sale_story"]           \
         }
       end).()
  end

  @doc """
  Translate  `Timex` date  to  human-readable form  of
  `<weekday>, <month> <day>, <year>`, e.g., Wednesday,
  June 7, 2022".

  NOTE 2022_06_03T0722
  Not dealing with ordinals for now as the whole point
  of this exercise is to feed  it to a TTS engine, and
  so far  both Google's and Azure's  solutions add the
  ordinals automatically. Will worry  about it if this
  needs to be printed somewhere.
  """
  defp to_human_date(timex_date) do
  end

  # def to_string(%__MODULE__.Flyer{} = flyer) do
  #   out_string = [ "Safeway's #{flyer.name}; valid from 
  # end

  # def to_string(%__MODULE__.Product{ coupon: true} = product) do
  # # "#{p.name}; #{p.description}  #{p.pre_price_text} #{p.price_text} #{p.post_price_text} #{p.disclaimer}"
  # end
end
