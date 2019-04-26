// Send to mongo to rename a whole bunch of 
// nohup mongo < 119.rename.js &
  
use htgd
db.registry.updateMany({}, {$rename:{"author_addl_t":"author_additional", "author_headings":"author", "enumchron_display":"enum_chron", "isbn_t":"isbn", "issn_t":"issn", "lc_callnum_display":"lc_call_numbers", "lccn_t":"lccn", "material_type_display":"material_type", "oclcnum_t":"oclc", "print_holdings_t":"print_holdings", "published_display":"place_of_publication", "publisher_headings":"publisher", "publisher_t":"publisher_all", "subtitle_display":"subtitle", "sudoc_display":"sudocs", "title_added_entry_t":"title_added_entry", "title_addl_t":"title_additional", "title_display":"title_normalized", "title_series_t":"title_series"}})

use test
db.registry.updateMany({}, {$rename:{"author_addl_t":"author_additional", "author_headings":"author", "enumchron_display":"enum_chron", "isbn_t":"isbn", "issn_t":"issn", "lc_callnum_display":"lc_call_numbers", "lccn_t":"lccn", "material_type_display":"material_type", "oclcnum_t":"oclc", "print_holdings_t":"print_holdings", "published_display":"place_of_publication", "publisher_headings":"publisher", "publisher_t":"publisher_all", "subtitle_display":"subtitle", "sudoc_display":"sudocs", "title_added_entry_t":"title_added_entry", "title_addl_t":"title_additional", "title_display":"title_normalized", "title_series_t":"title_series"}})

