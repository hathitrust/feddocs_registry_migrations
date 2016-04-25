require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

#some hathitrust records slipped in because I did not ensure the 086 was for a sudoc
def has_sudoc marc
  field_086 = marc['fields'].find {|f| f['086'] }
  if field_086 and 
    (field_086['086']['ind1'] == '0' or field_086['086']['a'] =~ /:/)
    return true 
  else
    return false
  end
end


source_count = 0
reg_count = 0
SourceRecord.where({org_code: "miaahdl", 
                    "source.fields":{"$elemMatch": {"086":{"$exists":1}}}, 
                    deprecated_timestamp:{"$exists":0}}).no_timeout.each do |rec|
  field_008 = rec.source['fields'].find {|f| f['008'] }['008']

  if field_008 !~ /^.{17}u.{10}f/ and !has_sudoc(rec.source)
    source_count += 1 
    rec.deprecate("#{REPO_VERSION}: Not a US Federal Document.")
    #deprecate a related registry record if it's the only source for it.
    RegistryRecord.where({source_record_ids: rec.source_id}).each do | regrec |
      if regrec.source_record_ids.count == 1
        reg_count += 1
        regrec.deprecate("#{REPO_VERSION}: Not a US Federal Document.")
      end
    end
  end

end
puts "HT Records deprecated: #{source_count}"
puts "RegRecs deprecated: #{reg_count}"

