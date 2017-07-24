require 'net/http'
require 'json'
require 'mongo'
require 'ap'

File.truncate('mongo.log', 0)
Mongo::Logger.logger = ::Logger.new('mongo.log')
$CLIENT = Mongo::Client.new('mongodb://127.0.0.1:27017/exileinfo')

def request(url)
  uri = URI(URI.encode(url))
  response = Net::HTTP.get(uri)
  return JSON.parse(response)
end

def collection(name)
  collection = $CLIENT[name]
  collection.drop
  return collection
end

###############################################################################
# Gets all the main leagues
data = request('http://api.pathofexile.com/leagues?type=main')
# ap data

col = collection('leagues')

col.insert_many(data)

puts "\n"
puts "Inserted #{col.count()} values into #{col.name}"
puts "\n"

$leagues = Array.new
col.find.each do |league|
  $leagues << league[:id]
end
###############################################################################

$leagues.each do |league|
  col = collection('characters ('+league+')')

  puts "\n"
  puts "Getting characters of "+league
  puts "\n"

  # CHANGE TO 75
  1.times do |value| # starts at 0 end at 74
    # CHANGE LIMIT TO 200
    data = request('http://api.pathofexile.com/ladders/'+league+'?limit=1&offset='+(value*200).to_s)

    data["entries"].each do |character|
      puts "\n"
      puts "Trying to get data off "+character["account"]["name"]+" / "+character["character"]["name"]
      puts "\n"
      items = request('https://www.pathofexile.com/character-window/get-items?accountName='+character["account"]["name"]+'&character='+character["character"]["name"])
      tree = request('https://www.pathofexile.com/character-window/get-passive-skills?accountName='+character["account"]["name"]+'&character='+character["character"]["name"])
      unless items == false || tree == false
        # ap items
        # ap tree
        profile = Hash.new
        profile["equipment"] = items
        profile["skilltree"] = tree
        # ap profile
        col.insert_one(profile)
        puts "\n"
        puts "Added "+character["account"]["name"]+" / "+character["character"]["name"]+" data"
        puts "\n"
      end
    end
  end

  puts "\n"
  puts "Inserted #{col.count()} values into #{col.name}"
  puts "\n"
end

puts "\n"
# https://www.pathofexile.com/character-window/get-items?accountName=K41C&character=tcKwz
# https://www.pathofexile.com/character-window/get-passive-skills?accountName=K41C&character=tcKwz
