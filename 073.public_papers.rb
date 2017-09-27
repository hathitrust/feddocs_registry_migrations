require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Parse enumchrons for Vital Statistics registry records 
#
=begin
=end
#
Pub = PublicPapersOfThePresidents
source_count = 0
rr_count = 0
PP.pp Pub.oclcs
SourceRecord.where(oclc_resolved:{"$in":Pub.oclcs}).no_timeout.each do |src|
  source_count += 1
  src.series = src.series
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":"Public Papers Of The Presidents"}).no_timeout.each do |r|
    r.series = r.series
    rr_count += 1
    r.save
  end
end
puts "Publick Paper sources: #{source_count}"
puts "Initial RR count: #{rr_count}"

deprecate_count = 0
rr_count = 0

SourceRecord.where(series:"PublicPapersOfThePresidents", 
                   deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  src.source = src.source.to_json #re-extraction done here
  res = src.update_in_registry("Improved enum/chron parsing. #{REPO_VERSION}") #this will take care of everything
  deprecate_count += res[:num_deleted]
  rr_count += res[:num_new]
  src.save
end
puts "# new RegRecs: #{rr_count}"
puts "Deprecated records: #{deprecate_count}"
puts "Source records: #{source_count}"
