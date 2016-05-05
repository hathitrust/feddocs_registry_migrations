require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# Add source_org_codes to registry records 

source_count = 0
reg_count = 0
RegistryRecord.where({deprecated_timestamp:{"$exists":0}}).no_timeout.each do |rec|
  reg_count += 1
  rec.source_org_codes ||= []
  rec.source_record_ids.each do | src_id |
    source_count += 1 
    src = SourceRecord.where({source_id:src_id}).first
    rec.source_org_codes << src.org_code
  end
  rec.source_org_codes = rec.source_org_codes.flatten.uniq
  rec.save
end
puts "Source records: #{source_count}"
puts "RegRecs: #{reg_count}"

