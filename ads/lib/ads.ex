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
    # -> {:ok, conn, request_ref} where `request_ref` identifies responses in the output of `Mint.HTTP.stream/2` 
  end

  def safeway_parse_publication_list(jsonRaw) do
    {:ok, json} = Jason.decode(jsonRaw)
    Enum.map(json, &(Map.get(&1, "id")))
  end

  def f(conn) do
    receive do

      # {:ssl, _, _} = ssl ->
      #   IO.inspect(ssl, label: :ssl)
      #   conn

      message ->
        IO.puts("\n")
        IO.puts("=== ENTER =================================================")
        IO.inspect(message, label: :message)
        IO.puts("\n")

        case Mint.HTTP.stream(conn, message) do
          {:ok, conn, responses} = mintStream ->
            IO.puts("\n")
            IO.puts("=== :ok MINT STREAM =======================================")
            IO.inspect(mintStream, label: :mintStream)
            IO.puts("\n")
            # IO.inspect(conn, label: :conn)
            # IO.inspect(responses, label: :responses)
            case Enum.filter(responses, &(elem(&1,0) === :data)) do
              [] ->
                IO.puts("\n")
                IO.puts("=== BUMMBER [] ============================================")
                IO.inspect(mintStream, label: :mintStream)
                IO.puts("\n")
                f(conn)
              [{:data, _ref, zippedJSON} | _] = flyerData ->
                IO.puts("\n")
                IO.puts("=== :data BRANCH ==========================================")
                IO.inspect(mintStream, label: :mintStream)
                IO.puts("   ========================================================")
                IO.puts("length(flyerData): #{length(flyerData)}")
                IO.puts("   ========================================================")
                IO.inspect(flyerData, label: :flyerData)
                IO.puts("\n")
                # 1. the actual flyer is loooong so recursively check
                #    for ":done" (right? Not sure what it is supposed
                #    to look like; check Mint.request/5 docs.)
                # 2. move this json parsing to the :done branch
                jsonRaw =
                  zippedJSON
                  |> :zlib.gunzip()
                  |> IO.inspect(label: :json)
                {conn, jsonRaw}
            end

          {:error, conn, reason, responses} ->
            IO.puts("\n")
            IO.puts("=== :error MINT STREAM ====================================")
            IO.inspect(other, label: :error)
            IO.puts("\n")
            f(conn)

          :unknown ->
            IO.puts("\n")
            IO.puts("=== :unknown MINT STREAM ==================================")
            IO.puts("\n")
            f(conn)
        end
    after
      0 ->
        IO.puts("=== after BRANCH ==========================================")
        {:no_data, conn}
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

