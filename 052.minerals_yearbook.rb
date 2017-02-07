require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Parse enumchrons for Minerals Yearbook registry records 
#
deprecate_count = 0
source_count = 0
rr_count = 0

=begin
=end
#
source_count = 0
rr_count = 0
SourceRecord.where(oclc_resolved:{"$in":MineralsYearbook.oclcs}).no_timeout.each do |src|
  source_count += 1
  src.series = "MineralsYearbook"
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":"Minerals Yearbook"}).no_timeout.each do |r|
    r.series = "Minerals Yearbook"
    rr_count += 1
    r.save
  end
end
puts "MY sources: #{source_count}"
puts "Initial RR count: #{rr_count}"

SourceRecord.where(series:"MineralsYearbook", 
                   deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  # wth flasus?
  if src.org_code == 'flasus'
    f = src.source['fields'].find {|f| f['955'] }['955']['subfields']
    v = f.select { |h| h['v'] }[0]
    junk_sf = f.select { |h| h.keys[0] =~ /\./ }[0]
    if !junk_sf.nil?
      junk = junk_sf.keys[0]
      v['v'] = junk
      f.delete_if { |h| h.keys[0] =~ /\./ }
    end
  end

  src.source = src.source.to_json #re-extraction done here
  res = src.update_in_registry("Improved enum/chron parsing. #{REPO_VERSION}") #this will take care of everything
  deprecate_count += res[:num_deleted]
  rr_count += res[:num_new]
  src.save
end

puts "# new RegRecs: #{rr_count}"
puts "Deprecated records: #{deprecate_count}"
puts "Source records: #{source_count}"
