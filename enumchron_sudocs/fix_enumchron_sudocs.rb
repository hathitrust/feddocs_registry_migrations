require 'registry/source_record'
require './header'

# some sudocs are masquerading as enumchrons try to fix them
SR = Registry::SourceRecord
RR = Registry::RegistryRecord
source_ids = []
num_deleted = 0
num_new = 0

open(ARGV.shift).each do | line |
  regid = line.chomp

  reg = RR.where(registry_id:regid).first
  if reg.source_org_codes != ['dgpo']
    #puts [regid, reg.source_org_codes.join(',')].join("\t")
  end

  if reg.deprecated_timestamp
    next
  end

  reg.source_record_ids.each do | src_id |
    if !source_ids.include? src_id
      src = SR.where(source_id:src_id).first
      src.source = src.source.to_json
      src.save
      res = src.update_in_registry "SuDocs were pretending to be Enum/Chron"
      num_deleted += res[:num_deleted]
      num_new += res[:num_new]
    end
  end
end
puts "num_deleted: #{num_deleted}"
puts "num_new: #{num_new}"
