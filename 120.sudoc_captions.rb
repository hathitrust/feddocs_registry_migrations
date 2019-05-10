# Some records have sudoc captions instead of actual sudocs.
# "I 19.81:(nos.-letters)/(ed.yr.)"
# Reprocess source records and registry records then recluster
require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
sr_count = 0
src_ids = []
SourceRecord.where(deprecated_timestamp:{"$exists":0},
                   sudocs:'I 19.81:(nos.-letters)/(ed.yr.)').no_timeout.each do |sr|
  sr.extract_sudocs
  if sr.sudocs.include("I 19.81:(nos.-letters)/(ed.yr.)")
    puts 'Error in reprocessing'
    exit
  end
  sr.save
  src_ids << sr.source_id
  sr_count += 1
end
puts src_ids
puts "Src Count:#{sr_count}"
num_reg_recs = 0 
# Deprecate existing Registry Records with bogus sudocs
RegistryRecord.where(deprecated_timestamp:{"$exists":0},
                     sudocs:'I 19.81:(nos.-letters)/(ed.yr.)').no_timeout.each do |r|
  num_reg_recs += 1
  r.deprecate("Removing bad SuDocs. #{REPO_VERSION}")
end
puts "Num reg recs removed:#{num_reg_recs}"

# Add those src records back in
src_ids.each do |src_id|
  sr = SourceRecord.where(source_id:src_id).first
  sr.update_in_registry("Removing bad SuDocs. #{REPO_VERSION}")
end

