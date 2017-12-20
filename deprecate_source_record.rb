require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'filter/blacklist'
require 'pp'

include Registry
sid = ARGV.shift
source_record = SourceRecord.where(source_id: sid,
                                   deprecated_timestamp:{"$exists":0}).first

if source_record.nil?
  puts "Does not exist"
  exit
end

source_record.deprecate("Erroneous metadata causing problems with misclustering")

reg_count = 0
RegistryRecord.where(source_record_ids:sid,
                     deprecated_timestamp:{"$exists":0}).each do |r|
  r.source_record_ids.delete(sid)
  r.recollate
  r.save 
  reg_count += 1
end

puts "RegRecs affected: #{reg_count}"
