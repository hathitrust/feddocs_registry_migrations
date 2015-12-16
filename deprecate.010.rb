require 'registry_record'
require 'source_record'
require './header' 

#Newsbank
recs = RegistryRecord.where(:publisher_viaf_ids => [152440057])
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
puts "Newsbank Registry Records deprecated: #{reg_count}"
puts "Newsbank Source Records deprecated: #{source_count}"

#Readex
recs = RegistryRecord.where(:publisher_normalized => /READEX.*/)
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
puts "Readex Registry Records deprecated: #{reg_count}"
puts "Readex Source Records deprecated: #{source_count}"

