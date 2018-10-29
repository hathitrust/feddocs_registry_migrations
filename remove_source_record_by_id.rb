require 'traject'
require 'marc'
require 'pp'
require 'registry/registry_record'
require 'registry/source_record'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(ENV['MONGOID_CONF'], :production)

# https://tools.lib.umich.edu/jira/browse/HT-856
# The title "Air Carrier Traffic at Canadian Airports" is largely caused by a 
# single record: 5ea8abb2-60b8-4483-8eb0-c1222a966355. 
#
# Remove it. 
num_removed_total = 0
source_id = ARGV.shift
SourceRecord.where(source_id:source_id,
                   deprecated_timestamp:{"$exists":0}
                  ).no_timeout.each do |src|
  num_removed = src.remove_from_registry('Not a US Federal Government Document.')
  num_removed_total += num_removed
  src.deprecate('Not a US Federal Government Document.')
end
puts "Num removed based on: #{num_removed_total}" 
