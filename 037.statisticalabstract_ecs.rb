require 'registry_record'
require 'source_record'
require 'statistical_abstract'
require './header' 
require 'pp'

# Parse enumchrons for Statistical Abstract registry records 

deprecate_count = 0

source_count = 0

oclcnums = StatisticalAbstract.oclcs 

# Each StatAb RegRec 
RegistryRecord.where(oclcnum_t:{"$in":oclcnums}, deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  #if we can parse it, then we should replace it. ignore if we can't. 
  ec = StatisticalAbstract.parse_ec(reg.enumchron_display)
  if ec.nil?
    next
  end

  #parsed and exploded replacement ECs.
  new_ids = [] 
  StatisticalAbstract.explode(ec).keys.uniq.each do | new_ec |
    r = RegistryRecord.new(reg.source_record_ids, new_ec, 'Statistical Abstract enumchron parsing.', [reg.registry_id])
    r.series = "Statistical Abstract"
    r.save
    new_ids << r.registry_id
  end

  reg.deprecate( 'Improved Statistical Abstract enum/chron parsing.', new_ids)
  deprecate_count +=1 
 
end

#lot of duplicates, merge them
merge_count = 0
all_reg_ids = RegistryRecord.where(oclcnum_t:{"$in":oclcnums}, 
                                   deprecated_timestamp:{"$exists":0}).no_timeout.pluck(:registry_id)
all_reg_ids.each do | reg_id |
  reg = RegistryRecord.where(registry_id:reg_id,
                             deprecated_timestamp:{"$exists":0}).no_timeout.first
  #possible we have already merged it
  if !reg
    next
  end

  #get all matching
  group = RegistryRecord.where(oclcnum_t:{"$in":oclcnums}, 
                               deprecated_timestamp:{"$exists":0},
                               enumchron_display:reg.enumchron_display).no_timeout.pluck(:registry_id)
  if group.count > 1
    RegistryRecord.merge( group, reg.enumchron_display, "Statistical Abstract enumchron parsing/merging.")
    merge_count += group.count
  end
end
puts "merge count: #{merge_count}"

# Parse the individual SourceRecord enumchrons
SourceRecord.where(series:"StatisticalAbstract",deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
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
  src.save
  source_count += 1

end

puts "Deprecated records: #{deprecate_count}"
puts "Source records: #{source_count}"

