require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# ~20k records have bad enumchrons consisting of: CIS US EXEC MF<sudoc>
# Delete the registry records, delete the enumchron in the source, and recluster

bad_reg_count = 0
add_reg_count = 0
new_reg_count = 0
src_count = 0
RegistryRecord.where({deprecated_timestamp:{"$exists":0}, 
                      enumchron_display:/^CIS US EXEC/}).no_timeout.each do |rec|
  bad_reg_count += 1
  rec.deprecate('Bad enum/chron')

  rec.sources.each do | src |
    src_count += 1
    if src.enum_chrons.count > 0
      src.enum_chrons = []
      ec = ""
      src.save
      if regrec = RegistryRecord::cluster( src, ec )
        regrec.add_source(src)
        regrec.save
        add_reg_count += 1
      else
        regrec = RegistryRecord.new([src.source_id], ec, "#{REPO_VERSION}: 028.cis enumchron removal")
        regrec.save
        new_reg_count += 1
      end
    end
  end
end
puts "SourceRecords updated: #{src_count}"
puts "bad reg count: #{bad_reg_count}"
puts "add reg count: #{add_reg_count}"
puts "new reg count: #{new_reg_count}"

