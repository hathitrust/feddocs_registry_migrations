require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Remove some Argentina records 
#
#
source_count = 0
regrec_count = 0
SourceRecord.where(author_lccns:'https://lccn.loc.gov/n50076615').no_timeout.each do |src|
  source_count += 1
  regrec_count += src.remove_from_registry('Not a Fed Doc. ID\'d by author LCCN')
end

puts "deprecated srcs: #{source_count}"
puts "deprecated regrecs: #{regrec_count}"
