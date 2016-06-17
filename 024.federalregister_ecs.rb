require 'registry_record'
require 'source_record'
require 'federal_register'
require './header' 
require 'pp'

# Parse enumchrons for Federal Register registry records 

deprecate_count = 0

source_count = 0

oclcnums = [1768512,
            3803349,
            9090879,
            6141934,
            27183168,
            9524639,
            60637209,
            25816139,
            27163912,
            7979808,
            4828080,
            18519766,
            41954100,
            43080713,
            38469925,
            97118565,
            70285150 ]


# Each FedReg RegRec 
RegistryRecord.where(oclcnum_t:{"$in":oclcnums}, deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  #if we can parse it, then we should replace it. ignore if we can't. 
  ec = FederalRegister.parse_ec(reg.enumchron_display)
  if ec.nil?
    next
  end

  #parsed and exploded replacement ECs.
  new_ids = [] 
  FederalRegister.explode(ec).keys.uniq.each do | new_ec |
    r = RegistryRecord.new(reg.source_record_ids, new_ec, 'Federal Register enumchron parsing.', [reg.registry_id])
    r.series = "Federal Register"
    #r.save
    new_ids << r.registry_id
  end

  #reg.deprecate( 'Improved Federal Register enum/chron parsing.', new_ids)
  deprecate_count +=1 
 
end

# Parse the individual SourceRecord enumchrons
SourceRecord.where(series:"FederalRegister",deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  src.ec = src.extract_enum_chrons
  if src.ec.keys.count > 0
    src.enum_chrons = src.ec.collect do |k,fields|
      if !fields['canonical'].nil?
        fields['canonical']
      else
        fields['string']
      end
    end
  else
    src.enum_chrons = ['']
  end
  #src.save
  source_count += 1

end

puts "Deprecated records: #{deprecate_count}"
puts "Source records: #{source_count}"

