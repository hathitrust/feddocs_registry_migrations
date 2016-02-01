require 'source_record'
require './header'

# Extract the id from HT's 001s, so we can use them for record updates. 

SourceRecord.where(:org_code => "miaahdl").each do | rec | 
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
    rec.save
  end
end



