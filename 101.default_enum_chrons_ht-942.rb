require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry

# Parse enumchrons that match '1896 PT. 1' or '1896 V. 1 PT. 1' 
# https://tools.lib.umich.edu/jira/browse/HT-942
source_count = 0
rr_count = 0
source_ids = []
RegistryRecord.where(enumchron_display:/^\d\d\d\d(\sV\.\s\d+)?\sPT\.\s\d+$/,
		     deprecated_timestamp:{"$exists":0}).no_timeout.each do |rec|
  rr_count += 1
  source_ids << rec.source_record_ids
end
puts "rr_count:#{rr_count}"

source_ids.flatten!
source_ids.uniq!

depped = [] # curiosity

source_ids.each do |src_id|
  SourceRecord.where(source_id:src_id).no_timeout.each do |src|
    if src.deprecated_timestamp
      depped << src_id 
    end
    src.source = src.source.to_json
    res = src.update_in_registry("Improved enum/chron parsing. #{REPO_VERSION}")
    src.save
  end
end

puts depped
puts "# previously deprecated source records(?!): #{depped.count}"
puts "# original RegRecs: #{rr_count}"
puts "# source ids: #{source_ids.count}"
