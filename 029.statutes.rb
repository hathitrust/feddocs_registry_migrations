require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# Add series info to Statutes At Large source records 

source_count = 0
deprecate_count = 0

oclcnums = [1768474,
	     4686465,
	     3176465,
	     3176512, 
	     426275236, 
	     15347313,
	     15280229, 
	     17554670, 
	     12739515, 
	     17273536 
	     ]

SourceRecord.where(oclc_resolved:{"$in":oclcnums}, series:{"$ne":"StatutesAtLarge"}).no_timeout.each do |src|
  source_count += 1
  src.series = "StatutesAtLarge"
  #src.save
end

puts "Source records: #{source_count}"

# Each Statute RegRec
RegistryRecord.where(oclcnum_t:{"$in":oclcnums}, deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  #if we can parse it, then we should replace it. ignore if we can't. 
  ec = StatutesAtLarge.parse_ec(reg.enumchron_display)
  reg.series = "Statutes At Large"
  #reg.save
  if ec.nil?
    next
  end

  #parsed and exploded replacement ECs.
  new_ids = [] 
  StatutesAtLarge.explode(ec).keys.uniq.each do | new_ec |
    r = RegistryRecord.new(reg.source_record_ids, new_ec, 'Statutes At Large enumchron parsing.', [reg.registry_id])
    r.series = "Statutes At Large"
    #r.save
    new_ids << r.registry_id
  end

  #reg.deprecate( 'Improved Statute at Large enum/chron parsing.', new_ids)
  deprecate_count +=1 
 
end
puts "deprecate: #{deprecate_count}"

merge_count = 0
# Merge duplicate RegRecs
all_reg_ids = RegistryRecord.where(series:"Statutes At Large",
                                   #oclcnum_t:{"$in":oclcnums}, 
                                   deprecated_timestamp:{"$exists":0}).no_timeout.pluck(:registry_id)
all_reg_ids.each do | reg_id |
  reg = RegistryRecord.where(registry_id:reg_id,
                             deprecated_timestamp:{"$exists":0}).no_timeout.first
  #possible we have already merged it
  if !reg
    next
  end

  #get all matching
  group = RegistryRecord.where(series:"Statutes At Large", 
                               deprecated_timestamp:{"$exists":0},
                               enumchron_display:reg.enumchron_display).no_timeout.pluck(:registry_id)
  if group.count > 1
    #RegistryRecord.merge( group, reg.enumchron_display, "Statutes At Large enumchron parsing/merging.")
    merge_count += group.count
  end
end
puts "merge count: #{merge_count}"
