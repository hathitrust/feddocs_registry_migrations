require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require './get_deprecated_oclcs'
require 'pp'

include Registry
# consume a list of OCLCs and deprecate related reg recs 
source_count = 0
reg_count = 0

#fin = open(ARGV.shift)
get_deprecated_oclcs.each do | line |
  oclc = line.chomp.split(/\t/)[0].to_i
  if oclc < 1
    next
  end

  SourceRecord.where(oclc_resolved: oclc, deprecated_timestamp:{"$exists":0})
                     .no_timeout.each do | srcrec |
    source_count += 1 
    srcrec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Identified by OCLC.")
  end


  # The comment below is no longer the case. We don't need to be that paranoid.
  # has ONLY this oclc. 
  # Occasionally bogus sources get clustered with legit RegRecs 
  # resulting in multiple OCLC numbers. Leave them be. 
  RegistryRecord.where(oclcnum_t: oclc,
                       deprecated_timestamp: {"$exists":0})
                       .no_timeout.each do | regrec | 
    reg_count += 1
    regrec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Identified by OCLC.")
    puts oclc
  end
end

puts "Source records deprecated: #{source_count}"
puts "RegRecs deprecated: #{reg_count}"

