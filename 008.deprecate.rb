require 'registry_record'
require 'source_record'
require './header'

#There are at least 4 VIAF ID's that fit Her Majesty's Stationery Office
#  134181633
#  134840354
#  132550134 ("His")
#  145979348 (replaced by 134840354?)
#  191260571 ("Stationary")

#Her Majesty's Stationery Office
#
RegistryRecord.where(:publisher_normalized => ["HMSO"]).update_all(:publisher_viaf_ids => [134181633])


recs = RegistryRecord.where(:publisher_viaf_ids => [134181633])
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
puts "134181633 Registry Records deprecated: #{reg_count}"
puts "134181633 Source Records deprecated: #{source_count}"

#fairly certain the initial update with 134181633 clobbers these, nothing of value was lost
recs = RegistryRecord.where(:publisher_viaf_ids => [134840354]) 
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
puts "134840354 Registry Records deprecated: #{reg_count}"
puts "134840354 Source Records deprecated: #{source_count}"


#We don't actually have any of these, "His Majesty..."
recs = RegistryRecord.where(:publisher_viaf_ids => [132550134])
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
puts "132550134 Registry Records deprecated: #{reg_count}"
puts "132550134 Source Records deprecated: #{source_count}"

recs = RegistryRecord.where(:publisher_viaf_ids => [145979348])
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
puts "145979348 Registry Records deprecated: #{reg_count}"
puts "145979348 Source Records deprecated: #{source_count}"

recs = RegistryRecord.where(:publisher_viaf_ids => [191260571])
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
puts "191260571 Registry Records deprecated: #{reg_count}"
puts "191260571 Source Records deprecated: #{source_count}"

