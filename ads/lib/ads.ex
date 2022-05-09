defmodule Ads do
  @moduledoc """
  Documentation for `Ads`.
  """

  def safeway_connect do
    connect("dam.flippenterprise.net")
  end

  def safeway_flipp_access_token do
    "7749fa974b9869e8f57606ac9477decf"
  end

  def safeway_headers do
    [{"accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"}, {"accept-encoding", "gzip, deflate, br"}, {"accept-language", "en-US,en;q=0.9,hu;q=0.8"}, {"cache-control", "no-cache"}, {"cookie", "_flyers_session=eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCMGtpRDNObGMzTnBiMjVmYVdRR09nWkZWRWtpSlRZeU5URTRNRGd6WTJNek9UZ3dOemM0TURobE5UWmhNemMyTkdSalpHWmtCanNBVkVraURYUmxjM1JmZG1GeUJqc0FSa2tpQm1ZR093QlUiLCJleHAiOiIyMDIyLTA4LTA1VDIxOjE5OjI2LjExMFoiLCJwdXIiOm51bGx9fQ%3D%3D--7d4183d3ddee74ad72b80114982d5dd8a3187ee5"}, {"pragma", "no-cache"}, {"sec-ch-ua", "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"101\", \"Google Chrome\";v=\"101\""}, {"sec-ch-ua-mobile", "?0"}, {"sec-ch-ua-platform", "\"Linux\""}, {"sec-fetch-dest", "document"}, {"sec-fetch-mode", "navigate"}, {"sec-fetch-site", "none"}, {"sec-fetch-user", "?1"}, {"upgrade-insecure-requests", "1"}, {"user-agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36"}]
  end

  def safeway_publication_list(conn) do
    path = "/flyerkit/publications/safeway?locale=en&access_token=#{safeway_flipp_access_token()}&store_code=654"
    request(conn, path, safeway_headers())
  end

  # Usually either the weekly flyer or big book of savings
  def safeway_publication(conn, id) do
    path = "/flyerkit/publication/#{id}/products?display_type=all&locale=en&access_token=#{safeway_flipp_access_token()}"
    request(conn, path, safeway_headers())
  end

  def connect(domain) do
    {:ok, conn} = Mint.HTTP.connect(:https, domain, 443 )
    conn
  end

  def request(conn, path, headers) do
    Mint.HTTP.request(conn, "GET", path, headers, "")
    # -> {:error, conn, reason}
    # -> {:ok, conn, request_ref}
    #
    #    where `request_ref` identifies responses returned by
    #    `Mint.HTTP.stream/2`  (i.e., after  the request  has
    #    been issued, messages from the request's destination
    #    will come into  the mailbox of the calling - in this
    #    case, this - process, which will become the argument
    #    of `stream/2`)
  end

  # `json` here is usually a list because Safeway has 2 active publications at any given time: the weekly ads and Big Book of Savings. With that said, this will crash if this is not caseand the input JSON is not a list.
  def safeway_parse_publication_list(json) do
    Enum.map(json, &(Map.get(&1, "id")))
  end

  def safeway_get_publications(conn) do
    {:ok, conn, request_ref} =
      conn
      |> safeway_connect()
      |> safeway_publication_list()

    {conn, aggregatedResponses} = Ads.collect_responses(conn)

    publication_list_ids =
      aggregatedResponses
      |> stream_data_by_request_to_json(request_ref)
      |> safeway_parse_publication_list()
      |> Enum.map(&(safeway_publication(conn, &1)))
    NOT DONE!
  end

  def collect_responses(conn) do
    collect_responses(conn, [])
  end

  # This will always empty the the process' message box. (TODO Make sure)
  def collect_responses(conn, aggregatedResponses) do

      # For HTTPS,  `message` usually has the  below format,
      # but not  important at this  point as it  is entirely
      # pushed through `Mint.HTTP.stream/2` right away.
      #
      # { :ssl
      # , { :sslsocket
      #   , {:gen_tcp, #Port<0.7>, :tls_connection, :undefined}
      #   , [#PID<0.235.0>, #PID<0.234.0>]
      #   }
      # , <<...>>
      # }

    receive do
      message ->
        IO.puts("\n")
        IO.puts("=== MESSAGE ===============================================")
        IO.inspect(message, label: :message)
        IO.puts("\n")

        IO.puts("=== Mint.HTTP.stream/2 ====================================")
        case (Mint.HTTP.stream(conn, message) |> tap(&IO.inspect/1)) do
          # -> :unknown
          #    a message not from the connection's socket
          #
          # -> {:error, conn, mintError, responsesList}
          #    `responsesList`  is  "a  list  of  responses  that  were
          #    correctly parsed before the error occured";
          #    see possible responses below
          #
          # -> {:ok, conn, responsesList}

          :unknown ->
            IO.puts("\n")
            IO.puts("=== :unknown MINT STREAM ==================================")
            IO.puts("\n")
            collect_responses(conn, aggregatedResponses)

          {:error, conn, mintError, responsesList} ->
            IO.puts("\n")
            IO.puts("=== :error MINT STREAM ====================================")
            IO.inspect(mintError, label: :error)
            IO.puts("\n")
            collect_responses(conn, aggregatedResponses ++ responsesList)

          {:ok, conn, responsesList} = mintStream ->
            IO.puts("\n")
            IO.puts("=== :ok MINT STREAM =======================================")
            IO.inspect(mintStream, label: :mintStream)
            IO.puts("\n")
            collect_responses(conn, aggregatedResponses ++ responsesList)
        end
    after
      0 ->
        # No messages at all or finished aggregating all the responses
        IO.puts("=== after BRANCH ==========================================")
        {conn, aggregatedResponses}
    end
  end

  def stream_data_by_request_to_json(aggregatedResponses, request_ref) do

    # Responses in `aggregatedResponses` have the following
    # form (from the `Mint.HTTP.stream/2` docs):
    #
    # + {:status,       request_ref, status_code                  }
    # + {:headers,      request_ref, headers                      }
    # + {:data,         request_ref, binary                       }
    # + {:done,         request_ref                               }
    # + {:error,        request_ref, reason                       }
    # + {:pong,         request_ref                               } HTTP/2 only
    # + {:push_promise, request_ref, promised_request_ref, headers} HTTP/2 only
    #

    IO.puts("\n")
    IO.inspect(aggregatedResponses, label: :all_responses)
    IO.puts("\n")

    # We only care about the `:data` right now:

    dataResponses =
      aggregatedResponses
      |> Enum.filter(&(elem(&1,0) === :data))
      |> Enum.filter(&(elem(&1,1) === request_ref))

    case dataResponses do

      [] ->
        IO.puts("\n")
        IO.puts("=== BUMMBER [] ============================================")
        IO.puts("\n")
        ""

      # The Safeway flyer's data is gzipped (see response headers) so they will need to be unzipped before use.
      # TODO Safeway uses Flipp, a couple other chains do too, but not sure about the rest.
      [{:data, ^request_ref, _zippedJSON} | _] = flyerData ->

        IO.puts("\n")
        IO.puts("=== :data BRANCH ==========================================")
        IO.puts("\n")

        flyerData
        |> Enum.reduce("", &(&2 <> elem(&1,2)))
        |> :zlib.gunzip()
        |> Jason.decode!()
    end
  end
end
# {:ok, conn} = Mint.HTTP.connect(:https, "dam.flippenterprise.net", 443 )
# {:ok, conn, req_ref} = Mint.HTTP.request(conn, "GET", "/flyerkit/publications/safeway?locale=en&access_token=7749fa974b9869e8f57606ac9477decf&store_code=654", [], "")
# receive do: (msg -> {:ok, conn, responses} = Mint.HTTP.stream(conn, msg))

 # "HTTP/1.1 403 Forbidden
# Server: CloudFront
# Date: Sat, 07 May 2022 21:14:38 GMT
# Content-Type: text/html
# Content-Length: 915
# Connection: keep-alive
# X-Cache: Error from cloudfront
# Via: 1.1 52c5c6677e1ddc37f9c7ddc8eee96130.cloudfront.net (CloudFront)
# X-Amz-Cf-Pop: BOS50-C1
# X-Amz-Cf-Id: 6YjCjDnQWiWtGECURo6X_qLpb8ncILO_7k2L4m3hTV7m6TnRNjfIYA==

# <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n<HTML><HEAD><META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=iso-8859-1\">\n<TITLE>ERROR: The request could not be satisfied</TITLE>\n</HEAD><BODY>\n<H1>403 ERROR</H1>\n<H2>The request could not be satisfied.</H2>\n<HR noshade size=\"1px\">\nBad request.\nWe can't connect to the server for this app or website at this time. There might be too much traffic or a configuration error. Try again later, or contact the app or website owner.\n<BR clear=\"all\">\nIf you provide content to customers through CloudFront, you can find steps to troubleshoot and help prevent this error by reviewing the CloudFront documentation.\n<BR clear=\"all\">\n<HR noshade size=\"1px\">\n<PRE>\nGenerated by cloudfront (CloudFront)\nRequest ID: 6YjCjDnQWiWtGECURo6X_qLpb8ncILO_7k2L4m3hTV7m6TnRNjfIYA==\n</PRE>\n<ADDRESS>\n</ADDRESS>\n</BODY></HTML>"}

# :authority: dam.flippenterprise.net
# :method: GET
# :path: /flyerkit/publications/safeway?locale=en&access_token=7749fa974b9869e8f57606ac9477decf&store_code=654
# :scheme: https

