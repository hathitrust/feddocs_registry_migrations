require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Parse enumchrons for Reports of Investigations registry records 
#
=begin
=end
#
source_count = 0
rr_count = 0
SourceRecord.where(oclc_resolved:{"$in":JournalOfTheNationalCancerInstitute.oclcs}, 
                  series:{"$ne":"JournalOfTheNationalCancerInstitute"}).no_timeout.each do |src|
  source_count += 1
  src.series = "JournalOfTheNationalCancerInstitute"
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":"Journal Of The National Cancer Institute"}).no_timeout.each do |r|
    r.series = "Journal Of The National Cancer Institute"
    rr_count += 1
    r.save
  end
end
puts "JNCI sources: #{source_count}"
puts "Initial RR count: #{rr_count}"

deprecate_count = 0
rr_count = 0

SourceRecord.where(series:"JournalOfTheNationalCancerInstitute", 
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
