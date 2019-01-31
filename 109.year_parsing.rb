require 'registry/registry_record'
require 'registry/source_record'
require 'ecmangle'
require './header' 
require 'pp'

include Registry
# Improve parsing of years 
#
#

source_count = 0
sources_we_need_to_reparse = []
RegistryRecord.where(deprecated_timestamp:{"$exists":0},
                     enumchron_display:/^\(\d\d\d\d\)$/).no_timeout.each do |regrec|
  sources_we_need_to_reparse << regrec.sources
end

sources_we_need_to_reparse.flatten.uniq.each do |src|
  source_count += 1
  src.source = src.source.to_json
  res = src.update_in_registry("Improved enum/chron parsing. #{REPO_VERSION}")
  src.save
end
  
puts "Source records: #{source_count}"
