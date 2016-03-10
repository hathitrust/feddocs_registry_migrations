require 'registry_record'
require 'source_record'
require './header' 

#Michigan State has ~220k records that are just HT record links
recs = SourceRecord.where(:org_code => "miem", :source_blob => /001...hth/)
source_count = 0
recs.each do | rec | 
  source_count += 1 
  rec.deprecate("#{REPO_VERSION}: Records (partially) copied from HathiTrust.")
  #deprecate a related registry record if it's the only source for it.
  RegistryRecord.where(:source_record_ids => [rec.source_id]).each do | regrec |
    regrec.deprecate("#{REPO_VERSION}: Records (partially) copied from HathiTrust.")
  end

end
puts "MSU/HT Records deprecated: #{source_count}"

