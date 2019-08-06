require 'registry/registry_record'
require 'registry/source_record'
require 'ecmangle'
require './header' 
require 'pp'

include Registry
# Parse enumchrons for Overseas Business Reports registry records 
#
ocns = [ 1792851, 557642861 ]

source_count = 0
rr_count = 0
SourceRecord.where(oclc_resolved:{"$in":ocns}).no_timeout.each do |src|
  source_count += 1
  src.series = src.series
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":'Overseas Business Reports'},
                       deprecated_timestamp:{"$exists":0}
                      ).no_timeout.each do |r|
    rr_count += 1
    r.series = r.sources.collect(&:series).flatten.uniq
    r.save
  end
end
puts "OBR sources: #{source_count}"
puts "Initial RR count: #{rr_count}"
deprecate_count = 0
rr_count = 0

SourceRecord.where(series:'Overseas Business Reports', 
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
