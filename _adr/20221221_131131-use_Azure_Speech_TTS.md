    title:  use Azure Speech's TTS API

    date:   2022-12-21 13:11
    status: accepted

TODO
    date:   2022-12-21 12:42
    status: implemented
    note: https://github.com/access-news/_/commit/667d3098cac55dc1340c79701cd4fe707bd986d3

## Context

The text generated from the JSONs of the store chains' APIs need to be converted into audio.

## Decision

Choose Azure's Speech service that has an SDK that supports Node.js (see [previous ADR](./20221221_124229-use_node_js_backend.md)) and we already have an existing Azure subscription.

## Consequences

Pros:

+ Going with a commercial service makes it faster and easier to implement this part of the Access News service.

+ The existing subscription causes less administrative overhead.

Cons:

+ Vendor lock-in

  TODO: Implement the audio conversion part of this project so that it is vendor-( and engine-)agnostic.

+ The Azure Speech SDK only supports a small number of languages and frameworks officially; if we ever decide to switch from Node.js (and/or JavaScript altogether), it will add extra complexity.


vim: set tabstop=2 shiftwidth=2 expandtab:
