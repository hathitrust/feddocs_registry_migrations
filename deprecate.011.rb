require 'registry_record'
require 'source_record'
require './header' 

#Michigan State has ~220k records that are just HT record links
source_count = 0
reg_count = 0
SourceRecord.where(:org_code => "miem", :source_blob => /001...hth/).no_timeout.each do | rec | 
  source_count += 1 
  rec.deprecate("#{REPO_VERSION}: Records (partially) copied from HathiTrust.")
  #deprecate a related registry record if it's the only source for it.
  RegistryRecord.where(:source_record_ids => [rec.source_id]).each do | regrec |
    reg_count += 1
    regrec.deprecate("#{REPO_VERSION}: Records (partially) copied from HathiTrust.")
  end

end
puts "MSU/HT Records deprecated: #{source_count}"
puts "RegRecs deprecated: #{reg_count}"

