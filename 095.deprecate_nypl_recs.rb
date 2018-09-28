require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series

# https://tools.lib.umich.edu/jira/browse/HT-588
#
# "Records from NYPL (nn) are the worst records in the Registry. 66% do not have OCNs. 79% are solo (don't match any other source). 
# https://docs.google.com/spreadsheets/d/10ZpsFhnF_HHGfDKK-TmEOr_CFep3fo8hoQ9bMDMsTHg/edit?usp=sharing
# Remove NYPL records either in toto, or based on presence of OCN or cataloging source, e.g. LexisNexis."
#
# For the first run, we will limit it to records without OCN or SuDocs. 

source_count = 0
regrec_count = 0
srcs_not_removed = []
SourceRecord.where(org_code:'nn',
                   "oclc_resolved.0":{"$exists":0},
                   "sudocs.0":{"$exists":0},
                   deprecated_timestamp:{"$exists":0} 
                  ).no_timeout.each do |src|
  
  # This would be the easy way, but we only want to deprecate records that don't match anything
  # regrec_count += src.remove_from_registry('Some records ...')
  RegistryRecord.where( source_record_ids:[src.source_id],
                        deprecated_timestamp:{"$exists":0}
                      ).no_timeout.each do |reg|
    regrec_count += 1
    reg.deprecate( "#{REPO_VERSION}: Some records without OCNs and SuDocs have been removed from the Registry.")
  end
  regrecs_remaining = RegistryRecord.where( source_record_ids:src.source_id,
                                            deprecated_timestamp:{"$exists":0}
                                          ).count  
  if regrecs_remaining == 0 
    src.deprecate("#{REPO_VERSION}: NYPL records without OCNS and SuDocs have been removed.")
    source_count += 1
  else
    srcs_not_removed << src.source_id
  end
end

puts "deprecated srcs: #{source_count}"
puts "deprecated regrecs: #{regrec_count}"
puts src_not_removed.join("\r")
