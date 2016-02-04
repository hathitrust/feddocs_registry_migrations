# Painfully stupid migration tracking. 

require './header' tracks commit id for deprecation/transformation.

header prevents completion if repo isn't clean.

In theory, transformations are idempotent. In theory. 

Move extraction/addition transformations (e.g. add_ht_ids) into ingest process?

Repeat deprecation transformations after ingest process?

