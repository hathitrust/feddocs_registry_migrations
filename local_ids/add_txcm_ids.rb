require 'source_record'
require './header'

# Extract the id from mh's 001s, so we can use them for record updates. 
count = 0
SourceRecord.where(:org_code => "txcm").each do | rec | 
  rec[:source][:fields].each do | f |
    if f["001"]
      rec.local_id = f["001"].chomp
      break #really should not have more than one 001
    end
  end

  #should not happen
  if !rec.local_id
    puts rec.source_id
  else
    count += 1
    rec.save
  end
end

puts "TXCM Ids added to #{count}"



