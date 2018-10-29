require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series

# Nothing works out as planned. I hacked apart 096...rb to use the ocns from
# the first round to fix the Registry Records. 096...rb is now up to snuff on
# its own.

# https://tools.lib.umich.edu/jira/browse/HT-859
#
# Among other problems with iaas records, we had erroneously included thme in
# the list of contributors with OCNs in the 001. While most of their records 
# have 'OCoLC' in the 003, they are not in fact OCoLCs. 
#
# Re-extract all Iowa records. Keep a list of the bogus OCNs so 
# we can investigate other records in the registry with those OCNs. 
#
# Also, most of their records have the same number from the 001 in an 035 field
# with a first indicator of "9" (invalid MARC). These may be Marcive 
# identifiers. This was presumed to be the problem, but in the case of Iowa it
# is not.

regrecs_recollated = 0
=begin
SourceRecord.where(org_code:'iaas',
                   deprecated_timestamp:{"$exists":0}
                  ).no_timeout.each do |src|

  old_ocns = src.oclc_resolved.clone
  old_alleged_ocns = src.oclc_alleged.clone
  src.source = src.source.to_json.gsub(/\{\s?"\$"\s?:/, '{"dollar":')

  src.save
  (old_ocns - src.oclc_resolved).each {|o| puts "#{o}:resolved"}
  (old_alleged_ocns = src.oclc_alleged).each {|o| puts "#{o}:alleged"}

  next if !(old_ocns - src.oclc_resolved).any?  
=end
File.open(ARGV.shift).each do |line|
  ocn = line.chomp.to_i
  RegistryRecord.where(oclcnum_t:ocn,
                       source_org_codes:"iaas",
                       deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg_rec|
    old_ocns = reg_rec.oclcnum_t.clone
    reg_rec.recollate
    if (old_ocns - reg_rec.oclcnum_t).any?
      regrecs_recollated += 1
      puts old_ocns - reg_rec.oclcnum_t
      reg_rec.save
    end
  end
=begin  RegistryRecord.where(source_record_ids:[src.source_id],
                       deprecated_timestamp:{"$exists":0}
                      ).no_timeout.each do |reg|
    reg.oclcnum_t = reg.sources.collect(&:oclc_resolved).flatten.uniq
    reg.save
    regrecs_recollated += 1
  end
=end
end
puts "recollated regrecs: #{regrecs_recollated}"
