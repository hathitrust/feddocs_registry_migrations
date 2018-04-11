require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# https://lccn.loc.gov/n80026021 to https://lccn.loc.gov/n78095330
# United States records had a bad lccn, it was a subject heading for treaties
# rather than entity.
# recollating should get us the correct lccns.
count = 0
RegistryRecord.where("$or":[{author_lccns:"https://lccn.loc.gov/n80026021"},
                            {added_entry_lccns:"https://lccn.loc.gov/n80026021"}],
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  reg.recollate
  count += 1
end

puts "num of registry records recollated: #{count}" 
