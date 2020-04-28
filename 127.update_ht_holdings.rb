require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry

# We have been updating Enum Chron parsing but not the holdings data for HT
# records. This leaves a mismatch in ec strings 

srcs_reextracted = 0
SourceRecord.where(org_code:"miaahdl",
                   deprecated_timestamp:{"$exists":0}
                  ).no_timeout.each do |src|
  srcs_reextracted += 1
  src.source = src.source.to_json
  src.save
end 

puts "srcs re extracted:#{srcs_reextracted}"
