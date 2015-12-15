require 'registry_record'
require 'source_record'
require './header' 

#publisher University of Texas Press"
recs = RegistryRecord.where(:publisher_viaf_ids=>[154811180])
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
puts "UTexas Registry Records deprecated: #{reg_count}"
puts "UTexas Source Records deprecated: #{source_count}"


#publisher National Security Archive"
recs = RegistryRecord.where(:publisher_viaf_ids=>[149090905, 166687191])
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
puts "NSA Registry Records deprecated: #{reg_count}"
puts "NSA Source Records deprecated: #{source_count}"


#publisher University of Nebraska Press"
recs = RegistryRecord.where(:publisher_viaf_ids=>[155098548])
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
puts "UNebraska Registry Records deprecated: #{reg_count}"
puts "UNebraska Source Records deprecated: #{source_count}"


#publisher Commerce Clearing House"
recs = RegistryRecord.where(:publisher_viaf_ids=>[134780750])
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
puts "Commerce Clearing House Records deprecated: #{reg_count}"
puts "Commerce Clearing House Source Records deprecated: #{source_count}"


#publisher Congressional Information Service"
recs = RegistryRecord.where(:publisher_viaf_ids=>[143574231])
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
puts "Congressional Information Service Records deprecated: #{reg_count}"
puts "Congressional Information Service Source Records deprecated: #{source_count}"


#publisher University of Arkansas Press"
recs = RegistryRecord.where(:publisher_viaf_ids=>[152555993])
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
puts "UArkansas Registry Records deprecated: #{reg_count}"
puts "UArkansas Source Records deprecated: #{source_count}"


