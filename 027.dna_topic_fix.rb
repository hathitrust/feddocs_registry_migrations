require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# A few (15?) records from GPO have expanded initialism DNA to "Norske arbeiderparti."
# in the subject fields.
# We'll fix this in the Registry Record, but not the source record. 

reg_count = 0
RegistryRecord.where({deprecated_timestamp:{"$exists":0}, 
                      subject_t:"Norske arbeiderparti."}).no_timeout.each do |rec|
  reg_count += 1
  rec.subject_t.delete("Norske arbeiderparti.")
  if !rec.subject_t.include? "DNA"
    rec.subject_t << "DNA"
  end

  rec.subject_topic_facet.delete("Norske arbeiderparti.")
  if !rec.subject_topic_facet.include? "DNA"
    rec.subject_topic_facet << "DNA"
  end
  rec.save
end
puts "RegRecs: #{reg_count}"

