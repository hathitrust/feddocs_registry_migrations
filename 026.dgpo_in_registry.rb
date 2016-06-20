require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# 025 may have ommitted some records. Recalculate "in_registry" field for dgpo sources.

in_reg_count = 0
not_in_reg_count = 0

# all GPO source records with enum_chrons
SourceRecord.where(org_code:"dgpo",
                    deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|

  r = RegistryRecord.where(source_record_ids: src.source_id, 
                       deprecated_timestamp:{"$exists":0}).no_timeout.first 
  if r
    src.in_registry = true
    in_reg_count += 1
  else
    src.in_registry = false
    not_in_reg_count += 1
  end
  src.save

end

puts "Not in Registry: #{not_in_reg_count}"                   
puts "In Registry: #{in_reg_count}"

