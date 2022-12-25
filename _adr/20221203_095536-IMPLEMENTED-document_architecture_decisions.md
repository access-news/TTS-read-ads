    title:  document architecture decisions

    date:   2022-12-03 09:55
    status: accepted

    date:   2022-12-06 11:04
    status: implemented
    note: https://github.com/access-news/_/commit/667d3098cac55dc1340c79701cd4fe707bd986d3

## Context

The problem is well explained in the documents linked in the decision.

## Decision

Adopt a slightly modified version of [Michael Nygard's "lightweight" ADR template](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions), mentioned on [adr.github.io](https://adr.github.io/) (specifically in [this section](https://adr.github.io/#lightweight-adrs-should-be-adopted)).

## Consequences

Pros:
+ make architecture design decisions explicit
+ ability to follow the evolution of the project
+ learn from past mistakes in case of flawed reasoning with regards to bad decisions

Cons:

+ added management overhead (both time and effort)

+ no **architectural knowledge management** (AKM) in place at this time

  As time goes by and ADRs accumulate, it will be harder and harder to keep track of what happened unless figuring out a way to come up with a user-friendly representation other than combing through text files.

  (Graphs? Implement an event sourcing-style aggregation method to give a status on what decisions are currently active?)

+ This is the first attempt at adopting ADRs, and the modified Nygard-style may have to be replaced with another template (causing this ADR to be superseded).

+ Above items will need to addressed in subsequent ADRs, contributing to the bloat described above.

vim: set tabstop=2 shiftwidth=2 expandtab:
