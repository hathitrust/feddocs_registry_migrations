require 'registry/registry_record'
require 'registry/source_record'
require 'ecmangle'
require './header' 
require 'pp'

include Registry
# Remove duplicate GPO records
# https://tools.lib.umich.edu/jira/browse/HT-1039
# /l1/govdocs/jira_tickets/1039_gpo_dupes

prior_count = RegistryRecord.where(deprecated_timestamp:{"$exists":0}).count
puts "Prior count: #{prior_count}"

num_src_deprecated = 0
dupes_to_remove = File.open(ARGV.shift)

dupes_to_remove.each do | line|
  local_id = line.chomp

  srcs = []
  SourceRecord.where(org_code:"dgpo",
                     deprecated_timestamp:{"$exists":0},
                     local_id: local_id).order_by(_id: :desc).each {|src| srcs << src}
  rec_we_are_keeping = srcs.shift
  srcs.each do |src|
    src.remove_from_registry("Duplicate GPO record. #{REPO_VERSION}")
    src.deprecate("Duplicate GPO record. #{REPO_VERSION}")
    num_src_deprecated += 1
  end
end

after_count = RegistryRecord.where(deprecated_timestamp:{"$exists":0}).count
puts "After count: #{after_count}"

puts "Num srcs deprecated: #{num_src_deprecated}"
