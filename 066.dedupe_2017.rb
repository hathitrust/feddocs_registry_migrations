require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'
require 'json'

include Registry
include Registry::Series
# Great Deduping of 2017
# 
# Merging records with (all) matching OCLC, Pub Date, SuDoc, EnumChron
=begin
=end
#
REASON = "Dedupe on OCLC/SuDoc/PubDate/Enumchron."
num_merged = 0
num_new = 0
open(ARGV.shift).each do | dupes |
  rec = JSON.parse(dupes.chomp)

  recs = []
  RegistryRecord.where(oclcnum_t:rec['oclcnum_t'],
                       pub_date:rec['pub_date'],
                       sudoc_display:rec['sudoc_display'],
                       enumchron_display:rec['enumchron_display'],
                       deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
    recs << reg.registry_id
  end

  if recs.count > 1
    num_merged += recs.count
    num_new += 1
    new = RegistryRecord.merge(recs, rec['enumchron_display'], REASON)
  end
end

puts "# new RegRecs: #{num_new}"
puts "Deprecated records: #{num_merged}"
