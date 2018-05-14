# We have the new concordance table, update all the oclcs. 
require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'oclc_authoritative'
require 'pp'

include Registry
include OclcAuthoritative

num_updated = 0
num_seen = 0
source_ids = []
# run through the SourceRecords that contain OCLCs, 
# update their OCLCS 
SourceRecord.where(
  deprecated_timestamp:{"$exists":0},
  "oclc_alleged.0":{"$exists":1}
).no_timeout.each do |s|
  num_seen += 1
  if num_seen % 10000 == 0
    puts "num_seen: #{num_seen}" + ' ' + Time.now.strftime("%d/%m/%Y %H:%M")
    STDOUT.flush
  end
  
  orig_ocns = s.oclc_resolved.clone
  s.oclc_resolved = s.oclc_alleged.map { |o| resolve_oclc(o) }.flatten.uniq
  if orig_ocns.sort != s.oclc_resolved.sort
    num_updated += 1
    source_ids << s.source_id
    puts s.source_id
    s.save
  end
end
puts "Sources complete."
puts "num seen: #{num_seen}"
puts "num updated: #{num_updated}"
STDOUT.flush

num_seen = 0
num_regrecs_updated = 0
# use the list of updated sources to update their Regrecs
source_ids.each do |sid|
  RegistryRecord.where(
    deprecated_timestamp:{"$exists":0},
    source_record_ids:sid
  ).no_timeout.each do |r|
   
    num_regrecs_updated += 1
    
    # so we have a clue what's going on
    num_seen += 1
    if num_seen % 10000 == 0
      puts "num_seen: #{num_seen}" + ' ' + Time.now.strftime("%d/%m/%Y %H:%M")
      STDOUT.flush
    end
  end
end
puts "num updated:#{num_regrecs_updated}"
puts "num seen:#{num_seen}"
