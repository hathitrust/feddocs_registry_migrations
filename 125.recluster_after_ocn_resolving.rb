# recluster based on oclc followin a new oclc concordance table
require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry

num_new = 0
num_deprecated = 0
num_seen = 0

# 124.results_source_ids.txt.tmp
source_ids = File.open(ARGV.shift)

# run through the RegistryRecords that are from the updated source_ids
source_ids.each do |line|
  num_seen += 1
  src_id = line.chomp

  RegistryRecord.where(
    deprecated_timestamp:{"$exists":0},
    source_record_ids:src_id).no_timeout.each do |r|

    # get other clusters with the same oclcs and ec
    similar_recs = RegistryRecord.where(
      deprecated_timestamp:{"$exists":0},
      enum_chron: r.enum_chron,
      oclc:{"$in": r.oclc}).no_timeout.pluck(:registry_id)
    if similar_recs.uniq.count > 1
      num_new +=1 
      num_deprecated += similar_recs.uniq.count
      replacement = RegistryRecord.merge(similar_recs.uniq,
                                       r.enum_chron,
                                       'Reclustering with OCLCs. ' \
                                       'After new concordance table')
    end
  end
end

puts "num new:#{num_new}"
puts "num deprecated:#{num_deprecated}"
puts "num seen:#{num_seen}"
