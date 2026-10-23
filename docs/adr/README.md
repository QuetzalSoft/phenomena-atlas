# Architecture decision records

One file per decision that constrains future work, named `NNNN-short-title.md`.

Write one when a choice would otherwise be re-argued in six months, or when the reason
behind it is not visible from the code. Do not write one for a choice that is obvious
or easily reversed.

Each record states: Status, Context, Decision, Consequences. Consequences include the
bad ones. A record that only lists advantages is marketing, and is worthless to whoever
reads it later wondering why things are the way they are.

Records are immutable once accepted. To change a decision, write a new record that
supersedes the old one and mark the old one as superseded.
