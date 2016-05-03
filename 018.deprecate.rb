require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# deprecate Early English 

source_count = 0
reg_count = 0
SourceRecord.where({"source.fields.830.subfields":{"$elemMatch":{"a":/Early English Books/i}}})
                    .no_timeout.each do |rec|
  source_count += 1 
  rec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Early English Books.")
  RegistryRecord.where({source_record_ids: rec.source_id}).each do | regrec |
    reg_count += 1
    regrec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Early English Books.")
  end
end
puts "Early English source records deprecated: #{source_count}"
puts "Early English regRecs deprecated: #{reg_count}"

# deprecate Zambia
source_count = 0
reg_count = 0
SourceRecord.where({"source.fields.830.subfields":{"$elemMatch":{"a":/National Assembly of Zambia/i}}})
                    .no_timeout.each do |rec|
  source_count += 1 
  rec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Zambia.")
  RegistryRecord.where({source_record_ids: rec.source_id}).each do | regrec |
    reg_count += 1
    regrec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Zambia.")
  end
end
puts "Zambia source records deprecated: #{source_count}"
puts "Zambia regRecs deprecated: #{reg_count}"

