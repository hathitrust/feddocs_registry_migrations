require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Add series info to Statutes At Large source records 

source_count = 0
deprecate_count = 0
rr_count = 0

oclcnums = StatutesAtLarge.oclcs
SourceRecord.where(oclc_resolved:{"$in":oclcnums}, deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  source_count += 1
  src.source = src.source.to_json #re-extraction done here
  res = src.update_in_registry("Improved enum/chron parsing. #{REPO_VERSION}") #this will take care of everything
  deprecate_count += res[:num_deleted]
  rr_count += res[:num_new]
  src.save
end

puts "Source records: #{source_count}"
puts "# new RegRecs: #{rr_count}"
puts "Deprecated records: #{deprecate_count}"
