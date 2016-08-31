require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# deprecate Congressional Quarterly 

source_count = 0
reg_count = 0
SourceRecord.where({deprecated_timestamp:{"$exists":0}, 
                    "source.fields.260.subfields":{"$elemMatch":{"b":/Congressional Quarterly/i}}})
                    .no_timeout.each do |rec|
  source_count += 1 
  rec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Congressional Quarterly.")
  RegistryRecord.where({source_record_ids: rec.source_id}).each do | regrec |
    if !regrec.suppressed
      reg_count += 1
      regrec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Congressional Quarterly.")
    end
  end
end
puts "Source records deprecated: #{source_count}"
puts "RegRecs deprecated: #{reg_count}"

# deprecate Commerce Clearing House 

source_count = 0
reg_count = 0
SourceRecord.where({deprecated_timestamp:{"$exists":0},
                    "source.fields.260.subfields":{"$elemMatch":{"b":/Commerce Clearing House/i}}})
                    .no_timeout.each do |rec|
  source_count += 1 
  rec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Commerce Clearing House.")
  RegistryRecord.where({source_record_ids: rec.source_id}).each do | regrec |
    if !regrec.suppressed
      reg_count += 1
      regrec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Commerce Clearing House.")
    end
  end
end
puts "Source records deprecated: #{source_count}"
puts "RegRecs deprecated: #{reg_count}"

