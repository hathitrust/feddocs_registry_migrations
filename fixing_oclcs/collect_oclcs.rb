require 'registry_record'
require 'source_record'
require_relative '../header' 
require 'pp'
require 'mongo'
require 'dotenv'

Dotenv.load

OCLCPAT = 
  /
      \A\s*
      (?:(?:\(OCoLC\)) |
  (?:\(OCoLC\))?(?:(?:ocm)|(?:ocn)|(?:on))
  )(\d+)
  /x

Mongoid.load!("config/mongoid.yml", :development)
Mongo::Logger.logger.level = ::Logger::FATAL

@mc = Mongo::Client.new([ENV['mongo_host']+':'+ENV['mongo_port']], :database => 'htgd' )

recs = SourceRecord.where(:stated_oclcnum.exists => false )
recs.each do | rec |
  fields = {}
  rec[:source]["fields"].each do | f | 
    k = f.keys[0]
    if fields[k]
      fields[k].push f[k]
    else 
      fields[k] = [f[k]]
    end
  end

  if fields["003"] and fields["003"][0] =~ /OCoLC/i 
    rec.oclc_location = "001"
    rec.stated_oclcnum = fields["001"][0].gsub(/\D/, '')
  elsif fields["035"]
    fields["035"].each do | f | 
      as = f["subfields"].select { | sf | sf.keys[0] == "a" }
      zs = f["subfields"].select { | sf | sf.keys[0] == "z" }
      if as.count > 0 and OCLCPAT.match(as[0]["a"]) 
        rec.stated_oclcnum = $1

        zs.each do | z |
          if OCLCPAT.match(z["z"])
            @mc[:oclc_resolution].insert_one({:canceled => $1, :replacement => rec.stated_oclcnum})
          end
        end
      end
    end
  end

  rec.save
end
