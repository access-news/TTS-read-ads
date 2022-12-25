    title:  use node.js as backend to fetch flyers from store chains

    date:   2022-12-21 12:42
    status: accepted

    date:   2022-12-22 10:31
    status: implemented
    note:   commit a543cb5

## Context

The whole project started out with prototyping in the browser (see e.g., [this gist](https://gist.github.com/toraritte/a47ad823dd1b0769aac1bdf06191e84f#file-for_browser-js); WARNING: not the most up-to-date!), but the final steps to invoke a TTS engine needs to be done on the backend<sup><b>†</b></sup>.

<sup>\[†]: Technically, calls to a TTS engine could be done from the browser (e.g., see [this page in the Azure Speech docs](https://learn.microsoft.com/en-us/azure/cognitive-services/speech-service/quickstarts/setup-platform?pivots=programming-language-javascript&tabs=linux%2Cubuntu%2Cdotnet%2Cjre%2Cmaven%2Cbrowser%2Cmac%2Cpypi); it should show instructions in a tab called "Browser-based"), but then one would have to juggle around HTML pages, load it in the browser, etc. Why the fuss when there are backend JS engines, and Node.js is officially supported in the major commercial TTS engines?</sup>

## Decision

Adopt Node.js as a backend JavaScript framework. There are other contenders (namely, Deno and Bun), but Node.js is supported by major commercial TTS services.

### Why a JavaScript backend framework and not some other language?

The prototyping is done is JavaScript in Chrome's DevTools, and this way ca. 80% of the code can be copy pasted to a Node.js template that takes care of

1. fetching the JSONs from the APIs and
2. invoking the TTS API with the parsed text.

With any other language, the JavaScript snippet would have to be re-implemented with the chosen language's tools, taking up extra time and effort.

## Consequences

Pros:

+ prototype JavaScript snippet can be quickly incorporated into the backend application

Cons:

+ Performance?

  Not an issue at the moment as everything is manual (e.g., the audio files are uploaded to TR2 and arranged by hand for now), but as more frontends are implemented, we may have to revisit this.

+ Security?

  Node.js and NPM seem to have a lot of vulnerabilities, but right now this is not a concern for us, and the materials are not sensitive either.

vim: set tabstop=2 shiftwidth=2 expandtab:
