require 'registry_record'
require 'source_record'
require './header' 

# There are 123k RegRecs with enumchron of "ONLINE"
# Deprecate them.  identifiers/extract_776s.rb will get a lot of the source 
# recs back in.
reg_count = 0
RegistryRecord.where({enumchron_display:"ONLINE", 
                      deprecated_timestamp:{"$exists":0}}).no_timeout.each do |r|
  reg_count += 1
  r.deprecate("#{REPO_VERSION}: ONLINE is a bogus enumchron.")
end
puts "RegRecs deprecated: #{reg_count}"

