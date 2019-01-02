require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
# Source Record series titles were previously class names. We can now use
# actual titles. 
source_count = 0
SourceRecord.where(series:/^[^ ]+$/).no_timeout.each do |src|
  source_count += 1
  src.series
  src.save
end
puts "src count:#{source_count}"

# Registry series titles were restricted to capitalizing class names
regrec_count = 0
RegistryRecord.where(series:/Of/,
		     deprecated_timestamp:{"$exists":0}).no_timeout.each do |rec|
  regrec_count +=1
  rec.series = rec.sources.collect(&:series).flatten.uniq
  rec.save
end
puts "regrec count:#{regrec_count}"
