require 'registry_record'
require 'source_record'
require './header' 

# Due to various bugs and stupidity duplicate registry records
# got inserted. Dedupe. 
regs_merged = 0
new_regs = 0

#tab delimited file with OCLCNUM and Enumchron
#only duplicated oclcnum/enumchron pairs are included
#
#mongoexport is inconsistent with the order fields are output.
#we'll just do this twice 
#oe_dupes.txt
#eo_dupes.txt
o_e = open(ARGV.shift, 'r')
e_o = open(ARGV.shift, 'r')
reason = "#{REPO_VERSION}: Duplicate records."
o_e.each do | line |
  oclcnum_t, enumchron_display = line.chomp.split(/\t/)
  oclcs = oclcnum_t.split(/, /).collect {|o| o.to_i}

  reg_ids = []
  RegistryRecord.where(oclcnum_t: oclcs, 
                       enumchron_display: enumchron_display,
                       "source_record_ids.1":{"$exists":0},
                       deprecated_timestamp: {"$exists":0}).no_timeout.each do |reg|
    reg_ids << reg.registry_id
  end

  if reg_ids.count > 1
    regs_merged += reg_ids.count
    new_regs += 1
    r = RegistryRecord.merge(reg_ids, enumchron_display, reason)
  end
end

e_o.each do | line |
  enumchron_display, oclcnum_t  = line.chomp.split(/\t/)
  oclcs = oclcnum_t.split(/, /).collect {|o| o.to_i}

  reg_ids = []
  RegistryRecord.where(oclcnum_t: oclcs, 
                       enumchron_display: enumchron_display,
                       "source_record_ids.1":{"$exists":0},
                       deprecated_timestamp: {"$exists":0}).no_timeout.each do |reg|
    reg_ids << reg.registry_id
  end

  if reg_ids.count > 1
    regs_merged += reg_ids.count
    new_regs += 1
    r = RegistryRecord.merge(reg_ids, enumchron_display, reason)
  end
end


puts "regs_merged: #{regs_merged}"
puts "new regs: #{new_regs}"



