require 'registry/registry_record'
require './header'

#trim punctuation in the traject wasn't catching everything in title_display

RR = Registry::RegistryRecord

start_num = 0
RR.where(deprecated_timestamp:{"$exists":0},
         "title_display.1":{"$exists":1}).no_timeout.each do |reg|
  start_num += 1
  reg.recollate 
end

puts "Number with multiple title_displays at start: #{start_num}"

end_num = RR.where(deprecated_timestamp:{"$exists":0},
                   "title_display.1":{"$exists":1}).count
puts "Number with multtiple title_displays at end: #{end_num}"

 

