require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series

# https://tools.lib.umich.edu/jira/browse/HT-902?filter=-1
#
# While trying to fix bad publisher_headings, it was discovered that there more
# than 50k reg recs with deprecated source records. 
#
# Apparently I screwed up earlier clean up attempts. This will un-deprecate 
# those records, re-extract, and update in the registry.

# but_why_tho/reg_recs_with_deprecated_src_recs_uniqd.txt
File.open(ARGV.shift).each do |line|
  regrec_id = line.chomp

  regrec = RegistryRecord.where(registry_id:regrec_id,
                                deprecated_timestamp:{"$exists":0}).first
  next if regrec.nil?

  regrec.sources.each do |src|
    if src.deprecated_timestamp
      src.unset(:deprecated_timestamp)
      src.unset(:deprecated_reason)
      src.in_registry = true

      src.source = src.source.to_json
      results = src.update_in_registry("Fixed deprecated source records. #{REPO_VERSION}")
      puts results
    end
  end
end
