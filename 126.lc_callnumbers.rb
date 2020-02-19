require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series

# https://tools.lib.umich.edu/jira/browse/HT-2196
#
# Bad lc_call_numbers that consist of '" . "' blow up the indexing

srcs_reextracted = 0
SourceRecord.where(lc_call_numbers:" . ",
                   deprecated_timestamp:{"$exists":0}
                  ).no_timeout.each do |src|
  srcs_reextracted += 1
  src.source = src.source.to_json
  src.save
end 

regrecs_recollated = 0
RegistryRecord.where(lc_call_numbers:" . ",
                     deprecated_timestamp:{"$exists":0}
                    ).no_timeout.each do |reg|
  reg.recollate
  regrecs_recollated += 1

end

puts "re-extracted sources: #{srcs_reextracted}"
puts "recollated regrecs: #{regrecs_recollated}"
