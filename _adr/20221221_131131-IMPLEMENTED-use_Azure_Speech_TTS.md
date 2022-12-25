    title:  use Azure Speech's TTS API

    date:   2022-12-21 13:11
    status: accepted

    date:   2022-12-22 10:31
    status: implemented
    note:   commit a543cb5

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
