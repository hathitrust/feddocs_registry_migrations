require 'registry_record'
require 'source_record'
require './header' 

# undo creation of a bunch of Harvard registry records
# recs back in.
reg_count = 0
RegistryRecord.where(creation_notes:/^MH update: data/,
                      source_org_codes:["mh"], 
                      deprecated_timestamp:{"$exists":0}).no_timeout.each do |r|
  if r.source_org_codes.count == 1
    reg_count += 1
    r.deprecate("#{REPO_VERSION}: Harvard records were added without checking for item information.")
    s = SourceRecord.where(source_id:r.source_record_ids[0]).first
    s.deprecate("#{REPO_VERSION}: Harvard records were added without checking for item information.")
  end
end
puts "RegRecs deprecated: #{reg_count}"
