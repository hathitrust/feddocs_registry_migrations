require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Bad identifiers were filling fields with [null] causing erroneous matches 
#
#
source_count = 0
deprecate_count = 0
rr_count = 0
=begin
SourceRecord.where(deprecated_timestamp:{"$exists":0},
                   "$or":[
                     {lccn_normalized:nil},
                     {issn_normalized:nil},
                     {isbns_normalized:nil}]).no_timeout.each do |src|
  source_count += 1
  src.source = src.source.to_json
  res = src.update_in_registry("Fixed bad identifiers. #{REPO_VERSION}")
  src.save
  deprecate_count += res[:num_deleted]
  rr_count += res[:num_new]
end
=end
srcs = []
RegistryRecord.where(deprecated_timestamp:{"$exists":0},
                   "$or":[
                     {lccn_t:nil},
                     {issn_t:nil},
                     {isbn_t:nil}]).no_timeout.each do |r|
  r.deprecate("Bad identifiers led to incorrect clustering. #{REPO_VERSION}")
  srcs << r.source_record_ids
end

srcs.flatten!
srcs.uniq!
srcs.each do |src_id|
  SourceRecord.where(source_id:src_id).no_timeout.each do |src|
    res = src.update_in_registry("Fixed bad identifiers. #{REPO_VERSION}")
    src.save
    deprecate_count += res[:num_deleted]
    rr_count += res[:num_new]
  end
end

puts "# new RegRecs: #{rr_count}"
puts "Deprecated records: #{deprecate_count}"
puts "Source records: #{source_count}"
