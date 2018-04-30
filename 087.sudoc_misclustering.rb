require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# SuDocs were used for clustering without checking if they were complete. 
# Many were getting clusterd based on the stem (e.g. 'I 2:') creating 
# mega-clusters.

source_list = []
registry_ids = []

# Get all Regrecs with 5 (arbitrary) or more OCLCs and a sudoc_display that
# either ends with ':' or does not contain ':'
RegistryRecord.where("oclcnum_t.5":{"$exists":1},
                     "$or":[
                       {sudoc_display: /:$/},
                       {sudoc_display: /^[^:]+$/}
                     ],
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do |r|
  source_list << r.source_record_ids
  r.deprecate('Clustered on incomplete SuDocs')
  registry_ids << r.registry_id
end

source_list.flatten.uniq.each do |sid|
  src = SourceRecord.find_by(source_id:sid)
  src.update_in_registry('Fixed clustering on partial SuDocs.')
end  

puts "num sources:#{source_list.flatten.uniq.count}"
puts "num registry ids:#{registry_ids.flatten.uniq.count}"

