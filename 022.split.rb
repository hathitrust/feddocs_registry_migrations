require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# 132 DGPO records have the same bad OCLC #: 3741824
# No point in using .split()
#
# Deprecate. Remove bad oclc #, recluster

source_count = 0
reg_count = 0
new_r_count = 0

badrec = RegistryRecord.where(oclcnum_t:3741824, 
                     deprecated_timestamp:{"$exists":0}).first 

badrec.deprecate( "#{REPO_VERSION}: Bad oclc # caused mega-cluster.")

SourceRecord.where(oclc_resolved:3741824,
                  deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  source_count += 1
  src.oclc_resolved = [] #delete the bogus oclc 

  src.enum_chrons.each do | ec |
    if regrec = RegistryRecord.cluster(src, ec)
      regrec.add_source(src)
      reg_count += 1
    else
      new_r_count += 1
      regrec = RegistryRecord.new([src.source_id], ec, "#{REPO_VERSION}: reclustering after OCLC fix.")
    end
    regrec.save
  end
end

puts "Source records: #{source_count}"
puts "Existing RegRecs: #{reg_count}"
puts "New RegRecs: #{new_r_count}"

