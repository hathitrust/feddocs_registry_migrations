require 'registry_record'
require 'agricultural_statistics'
require 'source_record'
require './header' 
require 'pp'

# 032 was a mess. This fixes things.
oclcnums = AgriculturalStatistics.oclcs

# Get every AgStats Enumchron
enum_chrons = RegistryRecord.where(oclcnum_t:{"$in":oclcnums}, deprecated_timestamp:{"$exists":0}).no_timeout.pluck(:enumchron_display)
enum_chrons.uniq!
puts enum_chrons.count
PP.pp enum_chrons

#foreach enum_chron merge the RegistryRecords
num_deprecated = 0
enum_chrons.each do | ec |
  reg_ids = RegistryRecord.where(oclcnum_t:{"$in":oclcnums}, deprecated_timestamp:{"$exists":0}, enumchron_display:ec).no_timeout.pluck(:registry_id)
  r = RegistryRecord.merge( reg_ids, ec, "Agricultural Statistics enumchron parsing/merging.")
  r.series = "Agricultural Statistics"
  r.save
  num_deprecated += reg_ids.count
end
puts num_deprecated


