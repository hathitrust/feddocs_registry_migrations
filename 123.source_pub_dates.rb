require 'registry/registry_record'
require 'registry/source_record'
require 'ecmangle'
require './header' 
require 'pp'

include Registry

# Fix pub_dates that contain nulls
regrec_count = 0
RegistryRecord.where(deprecated_timestamp:{'$exists':0},
                     "$and":[{'pub_date.0':{'$exists':1}},
                             {pub_date: nil}]).each do |regrec|
  pub_dates = []
  regrec_count += 1
  if regrec_count % 10000 == 0
    puts "regrec_count:#{regrec_count}"
  end
  regrec.sources.each do |src|
    pub_dates << src.pub_date
    src.save
  end
  regrec.pub_date = pub_dates.flatten.uniq
  regrec.save
end

puts "regrec count:#{regrec_count}"
