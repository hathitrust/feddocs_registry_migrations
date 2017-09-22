require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry

# merge regrecs with identical oclcs and enumchrons

# take a premade list of oclcs and enumchrons
# mongoexport -d htgd -c registry -d '{deprecated_timestamp:{$exists:0}, "oclcnum_t.0":{$exists:1}}' -f oclcnum_t,enumchron_display --csv -o oclcs_enums.tsv
# sort oclcs_enums.tsv | uniq -c | sort -nr yada yada yada
num_depped = 0
num_created = 0
oe_pairs = open(ARGV.shift)
oe_pairs.each do | line |
  ocs,ec = line.chomp.split("\t")
  ec ||= ''
  oclcs = ocs.split(', ').map {|o| o.to_i}
  reg_ids = RegistryRecord.where(oclcnum_t:oclcs,
                                 enumchron_display:ec,
                                 deprecated_timestamp:{"$exists":0}).pluck(:registry_id)
  if reg_ids.count < 2
    puts "reg ids less than 2. Should not happen"
    puts "# deprecated: #{num_depped}"
    puts "# new: #{num_created}"
    exit
  end

  num_depped += reg_ids.count
  num_created += 1

  RegistryRecord.merge(reg_ids, ec, "Identical oclcnum_t and enumchron_display fields")
end

puts "# deprecated: #{num_depped}"
puts "# new: #{num_created}"
