require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Parse enumchrons for Congressional Serial Set registry records 
#
# 044 only caught the ones with the SuDoc. Now we will catch some with the OCLC
deprecate_count = 0
source_count = 0
rr_count = 0

=begin
=end
#
source_count = 0
rr_count = 0
SourceRecord.where(oclc_resolved:{"$in":CongressionalSerialSet.oclcs}, 
                  series:{"$ne":"CongressionalSerialSet"}).no_timeout.each do |src|
  source_count += 1
  src.series = "CongressionalSerialSet"
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":"Congressional Serial Set"}).no_timeout.each do |r|
    r.series = "Congressional Serial Set"
    rr_count += 1
    r.save
  end
end
puts "CSS sources: #{source_count}"
puts "Initial RR count: #{rr_count}"

SourceRecord.where(series:"CongressionalSerialSet", 
                   sudocs:{"$not":/^#{Regexp.escape(ForeignRelations.sudoc_stem)}/},
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
