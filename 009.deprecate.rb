require 'registry_record'
require 'source_record'
require './header' 

#record got borked at some point. smashed two unrelated together as one source record
recs = RegistryRecord.where(:registry_id=>"aff89ffc-8621-4262-85c2-df34667a4372")
reg_count = 0
source_count = 0
recs.each do | rec | 
  reg_count += 1 
  rec.deprecate("#{REPO_VERSION}: Broken record.")
  rec.sources.each do | s | 
    s.deprecate("#{REPO_VERSION}: Broken record.")
  end
  source_count += rec.sources.count
end
puts "Registry Records deprecated: #{reg_count}"
puts "Source Records deprecated: #{source_count}"

