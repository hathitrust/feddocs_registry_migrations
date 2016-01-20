#this doesn't need to be repeated. 
#TODO: rip the relevant bits out for SourceRecord.new()

require 'registry_record'
require 'source_record'
require_relative '../header' 
require 'pp'
require 'mongo'
require 'dotenv'
require 'library_stdnums'

Dotenv.load

#OCLCPAT taken from traject, except middle o made optional
OCLCPAT = 
  /
      \A\s*
      (?:(?:\(OCo?LC\)) |
  (?:\(OCo?LC\))?(?:(?:ocm)|(?:ocn)|(?:on))
  )(\d+)
  /x

Mongoid.load!("config/mongoid.yml", :development)
Mongo::Logger.logger.level = ::Logger::FATAL

@mc = Mongo::Client.new([ENV['mongo_host']+':'+ENV['mongo_port']], :database => 'htgd' )

#contributors with 001 stated
contrib_001 = {} 
contribs = open(ARGV.shift)
contribs.each { |line| contrib_001[line.chomp] = 1 }

count = 0
SourceRecord.all.each do | rec |
  count += 1
  rec[:oclc_alleged] = []
  rec[:oclc_resolved] = []
  rec[:lccn_normalized] = []
  rec[:issn_normalized] = []
  rec[:sudocs] = []
  rec[:isbns] = []
  rec[:isbns_normalized] = []

  rec[:source]["fields"].each do | f | 
    #########
    # OCLC

    #035a's and 035z's 
    if f["035"]
      as = f["035"]["subfields"].select { | sf | sf.keys[0] == "a" }
      zs = f["035"]["subfields"].select { | sf | sf.keys[0] == "z" }

      if as.count > 0 and OCLCPAT.match(as[0]["a"]) 
        oclc = $1.to_i
        if oclc
          rec[:oclc_alleged] << oclc
        end
        #stick the z's in a resolution collection
        zs.each do | z |
          if OCLCPAT.match(z["z"])
            @mc[:oclc_resolution].insert_one({:canceled => $1, :replacement => oclc})
          end
        end
      end
    end

    #OCLC prefix in 001
    if f["001"] and OCLCPAT.match(f["001"])
      rec[:oclc_alleged] << $1.to_i
    end

    #contributors who told us to look in the 001
    if f["001"] and contrib_001[rec[:org_code]] and /^(\d+)$/x.match(f["001"])
      rec[:oclc_alleged] << $1.to_i
    end

    #Indiana told us 955$o. Not likely, but...
    if rec[:org_code] == "inu" and f["955"]
      o955 = f["955"]["subfields"].select { | sf | sf.keys[0] == "o" }
      o955.each do | o | 
        if /(\d+)/.match(o["o"])
          rec[:oclc_alleged] << $1.to_i
        end
      end
    end

    #########
    # LCCN

    if f["010"] 
      as = f["010"]["subfields"].select { | sf | sf.keys[0] == "a" }
      zs = f["010"]["subfields"].select { | sf | sf.keys[0] == "z" }

      if as.count > 0 and as[0]["a"] != ''
        lccn = StdNum::LCCN.normalize(as[0]["a"].downcase)
        rec[:lccn_normalized] << lccn 
        #stick the z's in a resolution collection
        zs.each do | z | 
          @mc[:lccn_resolution].insert_one({:canceled => StdNum::LCCN.normalize(z["z"].downcase), :replacement => lccn})
        end 
      end
    end

    #########
    # ISSN

    if f['022']
      as = f["022"]["subfields"].select { | sf | sf.keys[0] == "a" }
      zs = f["022"]["subfields"].select { | sf | sf.keys[0] == "z" }

      if as.count > 0 and as[0]["a"] != ''
        issn = StdNum::ISSN.normalize(as[0]["a"])
        rec[:issn_normalized] << issn 
        #stick the z's in a resolution collection
        zs.each do | z | 
          @mc[:issn_resolution].insert_one({:canceled => StdNum::ISSN.normalize(z["z"]), :replacement => issn})
        end 
      end
    end

    #########
    # sudoc (086)
    if f["086"]
      as = f["086"]["subfields"].select { | sf | sf.keys[0] == "a" } #NR so 1
      zs = f["086"]["subfields"].select { | sf | sf.keys[0] == "z" }

      if as.count > 0 and as[0]["a"] != ""
        rec[:sudocs] << as[0]["a"]

        zs.each do | z | 
          @mc[:sudoc_resolution].insert_one({:canceled => z["z"], :replacement => as[0]["a"]})
        end
      end
    end

    ##########
    # ISBN
    if f["020"] 
      as = f["020"]["subfields"].select { | sf | sf.keys[0] == "a" } #NR so 1
      zs = f["020"]["subfields"].select { | sf | sf.keys[0] == "z" }

      if as.count > 0 and as[0]["a"] != ""
        rec[:isbns] << as[0]["a"]
        isbn = StdNum::ISBN.normalize(as[0]["a"])
        if isbn and isbn != ''
          rec[:isbns_normalized] << isbn 
          #stick the z's in a resolution collection
          zs.each do | z | 
            @mc[:isbn_resolution].insert_one({:canceled => StdNum::ISBN.normalize(z["z"]), :replacement => isbn})
          end 
        end
      end
    end

  end #each field

  rec[:oclc_alleged].uniq!
  #resolve our oclc
  rec[:oclc_alleged].each do | oa |
    @mc[:oclc_authoritative].find(:duplicates => oa).each do | ores | #1?
      rec[:oclc_resolved] << ores[:oclc]
    end
  end
  if rec[:oclc_resolved].count() == 0
    rec[:oclc_resolved] = rec[:oclc_alleged]
  end
  
  rec[:oclc_resolved].uniq!
  rec[:lccn_normalized].uniq!
  rec[:issn_normalized].uniq!
  rec[:sudocs].uniq!
  rec[:isbns].uniq!
  rec[:isbns_normalized].uniq!

  rec.save

  if count % 10000 == 0 
    print "#{count}\r"
    $stdout.flush
  end

end #each rec
