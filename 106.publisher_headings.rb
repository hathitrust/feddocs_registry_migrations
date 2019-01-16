require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry

# Prep work for: 
# https://tools.lib.umich.edu/jira/browse/HT-1042?filter=-1
#
# Most source records are missing the publisher_headings field because they
# were ingested after its extraction was defined. 
#
# Re-extract and save.
# This source id is one that was missing its publisher_headings field:
# 8bc22fa7-9d04-494f-8e61-9daf407acbfc
num_found_with_pub_heads = 0 
SourceRecord.where(deprecated_timestamp:{"$exists":0},
                   "publisher_headings.0":{"$exists":0},
                   "source.fields.260.subfields.b":{"$exists":1}).each do |src|
  if src.publisher_headings.any?
    src.save
    num_found_with_pub_heads += 1
  end
end
puts "num found with publisher headings:#{num_found_with_pub_heads}"
