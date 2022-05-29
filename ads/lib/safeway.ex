defmodule Ads.Safeway do

  # TODO 2022-05-25T1810
  # This started out as `GenServer` but left the `init/1` because this is basically initializing a connection to the Safeway ads URL and it may be useful when returning to a behaviour laer on.
  # (WHY MOVE ON FROM GenServer? Because this is not really a process but sequential execution of code with a `receive` loop (i.e., get the Safeway publications, then their contents, etc.). It seems more appropriate to write this as sequential code that could be made concurrent using `Task`s later (or even GenStage, Flow, Broadway if splitting to stages makes sense). If the store chain modules would all be `GenServer`s then those would have to started according to a schedule, and right now it seems easier to use `Task.async/3` with `:max_concurrency`.

  # QUESTION 2022-05-25T1817
  # Would `GenServer`/`GenStage`&co. make sense later on when a common pattern has been identified and to start it as workers with specific args from a pool?

  # ANSWER 2022-05-25T1849
  # I remember now: this may need to be a process because `Mint.request/3` is async, and piping the returned `conn` struct into `Ads.collect_responses/1` may not yield anything: its `receive` loop immediately starts going through the process' message box, perhaps concluding with `[]` if the timeout in the `after` clause is not enough. With a `GenServer` this wouldn't be an issue as after `init/1`, when there are any incoming messages, `handle_info/?` will take over automatically, making sure that all the messages will be handled, always. (The timeout may still be an issue, because these `GenServer`s shouldn't be long running processes, but then what should be the timeout? -> Idiot, just terminate the process once done with the appropriate tuple...)

  def init(_) do

    # safeway_request =
    data().domain
    |> Ads.connect()

    # { :ok, safeway_request }
  end

  def get_publications do

    domain  = data().domain
    path    = data().url_path_fns.publication_list.()
    headers = data().flipp_HTTP_headers

    { conn, publication_list_json } =
      Ads.fetch_json(
        domain,
        path,
        headers
      )

    publications =
      extract_and_remap_keys(publication_list_json)
      # =>
      # [
      #   %{"external_display_name" => "Weekly Ad", "id" => 4904491},
      #   %{"external_display_name" => "Big Book of Savings", "id" => 4861127}
      # ]

    Enum.reduce(
      publications,
      { conn, [] },
      &fetch_publication/2
    )
  end

  defp fetch_publication(publication, { conn, out_list }) do

    path =
      publication.id
      |> data().url_path_fns.publication.()

    headers =
      data().flipp_HTTP_headers

    { conn, publication_item_maplist } =
      Ads.fetch_json(
        conn,
        path,
        headers
      )

    { conn \
    , [
        Map.put_new(publication, :items, publication_item_maplist)
      | out_list
      ]
    }
  end

  # TODO 2022_05_23T1245
  # 1. There are other chains that use flipp so this can be refactored further
  # 2. This is configuration so figure out what would be the best way to store it (as config, it should definitely be an external input and not hard-coded here

  # TODO 2022_05_25T1936 SOLVED
  # A recursive data structure (like in Nix) would be nice here to make the `flipp_access_token` template below less error prone (i.e., renaming the function will break the URL). What would be the best solution here? Elixir has a templating lib, look into it.
  # SOLUTION:
  # https://stackoverflow.com/questions/47281111/is-there-an-equivalent-to-module-for-named-functions-in-elixir-erlang
  # https://stackoverflow.com/questions/36679379/elixir-call-method-on-module-by-string-name
  # https://stackoverflow.com/questions/49360006/convert-module-name-to-string-and-back-to-module
  def data do
    function_name = __ENV__.function |> elem(0)
    this_function = fn() -> apply(__MODULE__, function_name, []) end

    %{ domain: "dam.flippenterprise.net",
       flipp_access_token: "7749fa974b9869e8f57606ac9477decf",
       url_path_fns:
         %{ publication_list: fn() -> "/flyerkit/publications/safeway?locale=en&access_token=#{this_function.().flipp_access_token}&store_code=654" end,
           publication: fn(id) -> "/flyerkit/publication/#{id}/products?display_type=all&locale=en&access_token=#{this_function.().flipp_access_token}" end,
         },
       flipp_HTTP_headers: [{"accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"}, {"accept-encoding", "gzip, deflate, br"}, {"accept-language", "en-US,en;q=0.9,hu;q=0.8"}, {"cache-control", "no-cache"}, {"cookie", "_flyers_session=eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCMGtpRDNObGMzTnBiMjVmYVdRR09nWkZWRWtpSlRZeU5URTRNRGd6WTJNek9UZ3dOemM0TURobE5UWmhNemMyTkdSalpHWmtCanNBVkVraURYUmxjM1JmZG1GeUJqc0FSa2tpQm1ZR093QlUiLCJleHAiOiIyMDIyLTA4LTA1VDIxOjE5OjI2LjExMFoiLCJwdXIiOm51bGx9fQ%3D%3D--7d4183d3ddee74ad72b80114982d5dd8a3187ee5"}, {"pragma", "no-cache"}, {"sec-ch-ua", "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"101\", \"Google Chrome\";v=\"101\""}, {"sec-ch-ua-mobile", "?0"}, {"sec-ch-ua-platform", "\"Linux\""}, {"sec-fetch-dest", "document"}, {"sec-fetch-mode", "navigate"}, {"sec-fetch-site", "none"}, {"sec-fetch-user", "?1"}, {"upgrade-insecure-requests", "1"}, {"user-agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36"}]
    }
  end

  # `json` here is usually a list because Safeway has 2 active publications at any given time: the weekly ads and Big Book of Savings. With that said, this will crash if this is not caseand the input JSON is not a list.
  defp extract_and_remap_keys(publication_list_json) do

    keys_needed =
      [ "id"                    \
      , "external_display_name" \
      , "total_pages"           \
      , "valid_from"            \
      , "valid_to"
      ]

    publication_list_json
    |> Enum.map(
         &Map.take(&1, keys_needed)
       )
    # The  flipp-given JSON  keys may  change, so  if they
    # do,  they  only need  to  be  changed here  and  not
    # 27  times down  the  line  (e.g., "key_message"  and
    # "key_message_short" hold  exactly the same  value as
    # "external_display_name"so not sure  which one is the
    # canonical key to hold the name of the publication)
    #
    # Also, the keys are now atoms and not strings
    |> Enum.map(
         fn(map) ->
           %{ publication_id: map["id"]                      \
            , publication_name: map["external_display_name"] \
            , page_total: map["total_pages"]                 \
            , valid_from: map["valid_from"]                  \
            , valid_to:   map["valid_to"]
            }
         end
       )
  end
  # =>
  # [
  #   %{"external_display_name" => "Weekly Ad", "id" => 4904491},
  #   %{"external_display_name" => "Big Book of Savings", "id" => 4861127}
  # ]
end
