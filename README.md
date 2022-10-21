## Current state of affairs (as of commit 5373e7e)

This is how the repo looks like at the moment:

```text
.
├── ads/
│   └── ...
├── _how-it-began/
│   ├── 2-3_curl.js
│   ├── 2-3_curl.ts
│   ├── deno-run-commands
│   ├── read-ads.js
│   └── vim-views/
│       └── ...
├── LICENSE
├── pub_guide.beam
└── README.md
```

> NOTE: `GIT EXERCISE` tags
> TODOs marked with these tags are perfect beginner Git exercises. These can be solved in multiple ways, and each project has its own source control conventions. That is, they mostly adopt ones that are established in bigger, longer running projects, such as [the Linux codebase](https://github.com/torvalds/linux), but nothing is written in stone.
>
> Let me know which approach you prefer: would you like to figure them out by yourself (although these "exercises" are woefully underspecified at the moment),and ask for a hint whenever you need help; should I provide the commands with explanations at first, etc.
>
> Bottom lines is, you can't mess anything up - and if you feel that you did, it will be educational. Found [this article](https://www.folklore.org/StoryView.py?story=Make_a_Mess,_Clean_it_Up!.txt) in 2012, and has been one of my guiding stars ever since:)

Notes on the files and directories in this repo:

+ `README.md`

  What you are reading right now. You should start here, however chaotic it looks.

+ `LICENSE`

  The project is licensed under the [AGPL-3.0](https://toraritte.github.io/software-licensing-a-primer/#public-domain-software) open source license.

  <sup>Wrote a [software licensing primer](https://toraritte.github.io/software-licensing-a-primer) a couple years back when getting to the point where I couldn't avoid looking into them. Hasn't been read by anyone besides myself, so take it with a grain of salt.</sup>

+ `ads/`

  Planned to re-write the unfinished JavaScript application in Erlang or Elixir, but got sidetracked - and it may not even be the best approach.

  > TODO (GIT EXERCISE)
  > Not sure whether to delete it or not, so will hide it in a branch (`beam-rewrite`) for now.

+ `_how-it-began`

  This is where all the relevant source files and additional notes are.

  + `vim-views`

    My editor is Vim, and wanted to save all the open files and macros in a haste. Didn't know where to put these state files, and saved it in here on impulse...

    > TODO (GIT EXERCISE)
    > Delete it.

  + `2-3_curl.ts`

    Ignore this; it was supposed to be the pure TypeScript re-write of `2-3_curl.js`, but didn't get that far.

    > TODO (GIT EXERCISE)
    > Delete it. Will start a proper TS re-write (or just type the JS one gradually) when the time is right. It is also possible that we decide that all this needs to be on the server-side (or backend), and another programming language would be more suitable.

  + `2-3_curl.js`

    First things first: this file has been duplicated and renamed to a more "project-appropriate" name, `read-ads.js` (see below). No clue why I didn't delete it; it's definitely older, with less comments than `read-ads.js`. (You can compare `2-3_curl.js` and `read-ads.js` (or "do a diff", or simply "diff them") in your editor; here are (I think) [some good instructions for VS Code](https://vscode.one/diff-vscode/).)

    > TODO
    > Consolidate the two and then delete this one.

    The weird name comes from the Deno manual's chapter [2.3 The First Steps](https://deno.land/manual@v1.26.2/getting_started/first_steps). Here's a quick intro for Deno, and will elaborate in the next section why I was thinking about using it.

    > INFO What is [Deno](https://deno.land/)?
    > Their website says that Deno is a "_runtime for JavaScript_" which basically means that when Deno is installed, JavaScript programs can be run on your computer, on a server, etc. (i.e., on the backend or server-side), instead of only in a browser.

    > ASIDE (If the above explanation is confusing.)
    >
    > Initially, JavaScript was only used in the browsers: when one visits a URL, the browser starts downloading the website's assets (HTML, CSS, and JavaScript files; images, etc.), then begins rendering the page, and will start running the JavaScript code (if any) with its built in JavaScript interpreter. (Pressing <kbd>CTRL</kbd>+<kbd>SHIFT</kbd>+<kbd>j</kbd> will open the browser's JS console in Chrome and in Edge, so you can experiment with JS right away. This is how this project started actually; more on that below.)
    >
    > This means that people were only able to run JavaSript programs they wrote in the browser, until [Node.js](https://nodejs.org/en/) came along. Node.js made it possible to run JS programs in the terminal of a computer, and just use JavaScript as a general purpose programming language for tasks other than web development. (For example, one could use it to organize their files on their computer, [write an HTTP server with it](https://developer.mozilla.org/en-US/docs/Learn/Server-side/Node_server_without_framework), etc.)
    >
    > [Deno](https://deno.land/) is "simply" a newer JavaScript runtime to Node.js, and this project was started by Node.js' creator. (Yes, Node.js is still the most popular, only its creator moved on.)

    + `deno-run-commands`

      These are [Deno](https://deno.land/) commands to run `read-ads.js` on the provided URLs on the command line / terminal. They should work the same on Windows. The URL arguments in the file are part of Flipp's REST API.

      > INFO
      > [**Flipp**](https://flipp.com/) is a company that provides advertising and content distribution services (I think), and big chains (Walmart, Target, Safeway, Lidl?, etc.) are using them. That is, the companies provide the raw data (item names, images, specials, deal names, dates, etc.), Flipp stores them on their servers that can be queried by the retail companies' websites. Flipp also provides their own tools for composing this raw data and to represent it on the websites (probably with their JS framework, but this is speculation).
      >
      > This is good for us, because our script that works for a Flipp-backed flyer will probably work for other chains as well, as the API and the structure of the returned data is similar (or even the same). The problem is that it seems that their API is undocumented (or not made available to the public; at least, I couldn't find them) so we'll need to reverse engineer it by looking at the HTTP calls.
      >
      > **API** stands for "application programming interface", which is an abstract concept, but it is well-explained in [this article](https://www.mulesoft.com/resources/api/what-is-an-api). (Or it looked quite good to me.)
      >
      > **REST** stands for "representational state transwer", and it's kind of a tough one. The good news is that you can use REST APIs even if you don't really understand it even without understanding REST; this will be crucial only when we are going to create our own REST APIs.
      >
      > **Side note**: There is a **lot** of debate around REST, but the consensus is that almost no currently available REST APIs are implemented correctly (except for the simplest ones). I think the biggest problem is that people came up with their own interpretation of the [the doctoral dissertation where the concept of REST is founded](https://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm), and represent these these thoughts as authoritative principles. This happens a lot in tech... (I would recommend looking into the linked thesis; I read it when I was learning about APIs and the basics of HTTP, and even though I didn't understand most of it, it was still elucidating. Can't wait to find the time to read it again.)

      **Why are we using Deno?**
      I started prototyping all this in Chrome developer console in the browser, but the longer a script gets, the harder it is to deal with it with the browser's tools, and some operations (including other JS libraries, call out to other online sources, etc.) may not even be possible from the dev console. Plus, the project will inevitably get to a point where it needs to be committed into source control (usually Git), and eventually the repository needs to be placed online somewhere so that collaborators can access it.

      Therefore I needed to move this on my computer which also meant choosing a JavaScript runtime. Node.js is the most popular, but chose Deno because it is said to be more modern and more secure than the former. There are more and more options lately (the latest one is [Bun](https://bun.sh/)), so we should remain flexible about this, in case we need to change up. (And, again, we may have to move away from JS altogether.)

    + `read-ads.js`

      This is the most up to date version of the script, but still a little more than a prototype. Tried to comment it where I could, but some already don't make sense so just a heads up...

---

(Original intro:)

As far as I can tell, every single store (large or small, nationwide or local to a state, grocery or retail, etc.) puts out the same flyers everywhere, regardless of geographic location. Which is weird, given that most of the sites won't show the ads until a ZIP code is given and/or a store is chosen. (I presume this done to collect user statistics?)

## Chains using [flipp](https://corp.flipp.com/)

Couldn't find an public API description, but one can find the URLs of the API via Chrome's dev tools on the "Network" tab (TODO: insert methods from other browswers here).

### Safeway

#### 1. List available flyers (or "publications")

The URL we use to list available flyers (which usually means the weekly flyer and the Big Book of Savings) is this:

```
https://dam.flippenterprise.net/flyerkit/publications/safeway?locale=en&access_token=7749fa974b9869e8f57606ac9477decf&show_storefronts=true&postal_code=05403&store_code=3132
```

Even though only `locale`, `access_token`, and `store_code` is needed:

```
https://dam.flippenterprise.net/flyerkit/publications/safeway?locale=en&access_token=7749fa974b9869e8f57606ac9477decf&store_code=654
```

The return value is a JSON array of "publication" objects:

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
