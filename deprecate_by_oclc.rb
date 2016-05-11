require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# consume a list of OCLCs and deprecate related reg recs 
source_count = 0
reg_count = 0

fin = open(ARGV.shift)
fin.each do | line |
  oclc = line.chomp.split(/\t/)[0].to_i
  if oclc < 1
    next
  end

  SourceRecord.where(oclc_resolved: oclc, deprecated_timestamp:{"$exists":0})
                     .no_timeout.each do | srcrec |
    source_count += 1 
    srcrec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Identified by OCLC.")

    RegistryRecord.where(source_record_ids: srcrec.source_id,
                         deprecated_timestamp: {"$exists":0})
                         .no_timeout.each do | regrec | 
      reg_count += 1
      regrec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Identified by OCLC.")
    end
  end
end

puts "Source records deprecated: #{source_count}"
puts "RegRecs deprecated: #{reg_count}"

