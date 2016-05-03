require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# deprecate Confederacy docs

source_count = 0
reg_count = 0
SourceRecord.where({"source.fields.533.subfields":{"$elemMatch":{"f":/Confederate imprints/}}})
                    .no_timeout.each do |rec|
  source_count += 1 
  rec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Confederacy.")
  RegistryRecord.where({source_record_ids: rec.source_id}).each do | regrec |
    reg_count += 1
    regrec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Confederacy.")
  end
end
puts "Source records deprecated: #{source_count}"
puts "RegRecs deprecated: #{reg_count}"

