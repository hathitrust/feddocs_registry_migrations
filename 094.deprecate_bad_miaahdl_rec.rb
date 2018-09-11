require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Remove https://catalog.hathitrust.org/Record/10085562.marc 
#
#
source_count = 0
regrec_count = 0
SourceRecord.where(org_code:'miaahdl',
                   local_id:'10085562').no_timeout.each do |src|
  source_count += 1
  regrec_count += src.remove_from_registry('Not a Fed Doc. ID\'d by record id.')
end

puts "deprecated srcs: #{source_count}"
puts "deprecated regrecs: #{regrec_count}"
