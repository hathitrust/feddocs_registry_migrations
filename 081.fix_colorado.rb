# Colorado has some messed up oclcs.
require 'registry/registry_record'
require 'registry/source_record'
require 'pp'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(ENV['MONGOID_CONF'], :production)
num_recollated = 0
all_removed_oclcs = []
# Get all colorado source records with more than one alleged oclc
SourceRecord.where(org_code:'cou',
                   deprecated_timestamp:{"$exists":0},
                   "oclc_resolved.1":{"$exists":1}).no_timeout.each do |source_record|
  # Check if there is a difference when you remove bad oclcs
  original_oclcs = source_record.oclc_resolved.clone
  oo_count = original_oclcs.count
  source_record.extract_identifiers
  source_record.save
  next if original_oclcs.count == source_record.oclc_resolved.size
  removed_oclcs = original_oclcs - source_record.oclc_resolved
  all_removed_oclcs << removed_oclcs  
end
all_removed_oclcs.flatten.uniq!

all_removed_oclcs.each do |o|
# Get all registry records that have a bad and removed oclc
  RegistryRecord.where(oclcnum_t:o.to_i,
                    deprecated_timestamp:{"$exists":0}).no_timeout.each do |registry_record|
  # Recollate the registry record if none of its source records contain a bad oclc.
  unless registry_record.sources.any?{|s| (s.oclc_resolved & all_removed_oclcs).size > 0}
    num_recollated += 1
    registry_record.recollate
    next
  end
end

puts "num of bad oclcs:#{all_removed_oclcs.count}"
puts "num of recollated regrecs:#{num_recollated}"
