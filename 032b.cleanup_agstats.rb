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
  RegistryRecord.merge( reg_ids, ec, "Agricultural Statistics enumchron parsing/merging.")
  num_deprecated += reg_ids.count
end
puts num_deprecated
# This was a disaster. See 032b.cleanup for the fix to this nonsense.
=begin
# Add series info to Agricultural Statistics source records 

source_count = 0

oclcnums = AgriculturalStatistics.oclcs 
PP.pp oclcnums
enum_chrons = []

SourceRecord.where(oclc_resolved:{"$in":oclcnums} ).no_timeout.each do |src|
  source_count += 1
  src.ec = src.extract_enum_chrons
  if src.ec.keys.count > 0
    src.enum_chrons = src.ec.collect do |k,fields|
      if !fields['canonical'].nil?
        fields['canonical']
      else
        fields['string']
      end
    end
  else
    src.enum_chrons = ['']
  end
  src.series = "AgriculturalStatistics"
  src.save
  enum_chrons << src.enum_chrons
end

puts "Source records: #{source_count}"

reg_count = 0 
deprecate_count = 0

enum_chrons.flatten!.uniq!
#PP.pp enum_chrons
new_id_count = 0
# Add series info to Agricultural Statistics registry records 
RegistryRecord.where(oclcnum_t:{"$in":oclcnums}).no_timeout.each do |reg|
  reg.series = "Agricultural Statistics"
  reg.save
  #if we can parse it, then we should replace it. ignore if we can't. 
  ec = AgriculturalStatistics.parse_ec(reg.enumchron_display)
  if ec.nil?
    next
  end

  #parsed and exploded replacement ECs.
  new_ids = [] 
  AgriculturalStatistics.explode(ec).keys.uniq.each do | new_ec |
    r = RegistryRecord.new(reg.source_record_ids, new_ec, 'Agricultural Statistics enumchron parsing.', [reg.registry_id])
    r.series = "Agricultural Statistics"
    r.save
    new_ids << r.registry_id
  end
  new_id_count += new_ids.count
  reg.deprecate( 'Improved Agricultural Statistics enum/chron parsing.', new_ids)
  deprecate_count +=1 
 
end
puts "deprecate: #{deprecate_count}"
puts "new id count #{new_id_count}"

merge_count = 0
# Merge duplicate RegRecs
all_reg_ids = RegistryRecord.where(series:"Agricultural Statistics",
                                   deprecated_timestamp:{"$exists":0}).no_timeout.pluck(:registry_id)
all_reg_ids.each do | reg_id |
  reg = RegistryRecord.where(registry_id:reg_id,
                             deprecated_timestamp:{"$exists":0}).no_timeout.first
  #possible we have already merged it
  if !reg
    next
  end

  #get all matching
  group = RegistryRecord.where(series:"Agricultural Statistics", 
                               deprecated_timestamp:{"$exists":0},
                               enumchron_display:reg.enumchron_display).no_timeout.pluck(:registry_id)
  if group.count > 1
    RegistryRecord.merge( group, reg.enumchron_display, "Agricultural Statistics enumchron parsing/merging.")
    merge_count += group.count
  end
end
puts "merge count: #{merge_count}"
puts "Deprecated records: #{deprecate_count}"
puts "Registry records: #{reg_count}"
=end
