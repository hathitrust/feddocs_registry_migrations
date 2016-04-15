require 'registry_record'
require 'source_record'
require './header' 

recs = RegistryRecord.where(:author_t => ["Great Britain. Parliament. House of Commons."])
reg_count = 0
source_count = 0
recs.each do | rec | 
  reg_count += 1 
  rec.deprecate("#{REPO_VERSION}: Not a United States Federal Document.")
  rec.sources.each do | s | 
    s.deprecate("#{REPO_VERSION}: Not a United States Federal Document.")
  end
  source_count += rec.sources.count
end
puts "Registry Records deprecated: #{reg_count}"
puts "Source Records deprecated: #{source_count}"

