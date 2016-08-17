require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# Recalculate "in_registry" field for HT sources.

in_reg_count = 0
not_in_reg_count = 0
num_changed = 0
# all HT records 
SourceRecord.where(org_code:"miaahdl",
                    deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|

  r = RegistryRecord.where(source_record_ids: src.source_id, 
                       deprecated_timestamp:{"$exists":0}).no_timeout.first 
  if r
    if src.in_registry != true
      src.in_registry = true
      num_changed += 1
      src.save
    end
    in_reg_count += 1
  else
    if src.in_registry == true
      num_changed += 1
      src.in_registry = false
      src.save
    end
    not_in_reg_count += 1
  end
end

puts "Not in Registry: #{not_in_reg_count}"                   
puts "In Registry: #{in_reg_count}"
puts "# Changed: #{num_changed}"

