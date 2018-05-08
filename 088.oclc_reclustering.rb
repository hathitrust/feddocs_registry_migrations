# recluster based on oclc, in preparation for OCLC concordance table
require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry

pass = 0
num_new = 0
num_deprecated = 0
num_seen = 0

# run through the RegistryRecords that contain OCLCs, merging them, until
# we don't merge any more. 
while true
  pass += 1
  puts "pass: #{pass}"
  STDOUT.flush
  num_new_this_pass = 0

  RegistryRecord.where(
    deprecated_timestamp:{"$exists":0},
    "oclcnum_t.0":{"$exists":1}
  ).no_timeout.each do |r|
    next if r.deprecated_timestamp

    # so we have a clue what's going on
    num_seen += 1
    if num_seen % 10000 == 0
      puts num_seen
      STDOUT.flush
    end

    # get other clusters with the same oclcs and ec
    similar_recs = RegistryRecord.where(
      deprecated_timestamp:{"$exists":0},
      enumchron_display: r.enumchron_display,
      oclcnum_t:{"$in": r.oclcnum_t}).no_timeout.pluck(:registry_id)

    if similar_recs.uniq.count > 1
      num_new += 1
      num_new_this_pass += 1
      num_deprecated += similar_recs.count
      replacement = RegistryRecord.merge(similar_recs.uniq,
                                         r.enumchron_display,
                                         'Reclustering with OCLCs. ' \
                                         'Before new concordance table')
    end
  end
  puts "num new this pass: #{num_new_this_pass}"
  STDOUT.flush
  # we didn't merge any so we're done. 
  exit if num_new_this_pass == 0
end
puts "num new:#{num_new}"
puts "num deprecated:#{num_deprecated}"
puts "num seen:#{num_seen}"
