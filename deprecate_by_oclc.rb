require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'filter/blacklist'
require 'pp'

include Registry
# consume a list of OCLCs and deprecate related reg recs 
source_count = 0
reg_count = 0

deprecated_oclcs = Hash.new 0

#fin = open(ARGV.shift)
Blacklist.oclcs.each do | oclc |

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
    deprecated_oclcs[oclc] += 1
  end
end

deprecated_oclcs.each { |o, count| puts o + ": " + count }

puts "Source records deprecated: #{source_count}"
puts "RegRecs deprecated: #{reg_count}"

