require 'registry/registry_record'
require 'registry/source_record'
require 'ecmangle'
require './header' 
require 'pp'

SR = Registry::SourceRecord
RR = Registry::RegistryRecord

# JIRA issue HT-1162
# MH records got dragged in, presumably by INND records. Now that they are 
# deprecated we need to deprecate MH records that are solos and no indication
# of being fed docs. 
num_deprecated = 0
SR.where(org_code:"mh",
                   in_registry:true,
                   deprecated_timestamp:{"$exists":0}).no_timeout.each do | src |
  next if src.fed_doc?
  # is it solo in the Registry
  next if RR.where(source_record_ids:[src.source_id],
                               deprecated_timestamp:{"$exists":0}).count == 0
  src.deprecate("Does not appear to be a US Fed Doc. #{REPO_VERSION}")
  num_deprecated += 1
end
puts "num deprecated:#{num_deprecated}"
