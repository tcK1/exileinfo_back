require 'net/http'
require 'json'
require 'mongo'
require 'ap'

$CLIENT = Mongo::Client.new('mongodb://127.0.0.1:27017/exileinfo')

def request (url)
  uri = URI(url)
  response = Net::HTTP.get(uri)
  return JSON.parse(response)
end

def collection (name)
  collection = $CLIENT[name]
  collection.drop
  return collection
end

###############################################################################
# Gets all the main leagues
data = request('http://api.pathofexile.com/leagues?type=main')
# ap data

col_id = collection('leagues')

result = col_id.insert_many(data)

puts "\n"
puts "Inserted #{col_id.count()} values into #{col_id.name}"
puts "\n"

$leagues = Array.new
col_id.find.each do |league|
  $leagues << league[:id]
end
###############################################################################

$leagues.each do |league|
  col = collection('characters ('+league+')')

  # CHANGE TO 75
  1.times do |value| # starts at 0 end at 74
    data = request('http://api.pathofexile.com/ladders/'+col_id.find.first[:id]+'?limit=200&offset='+(value*200).to_s)
    # SHOULD VERIFY IF CHARACTER IS PUBLIC AND ADD IT TO THE COLLECTION
    result = col.insert_many(data["entries"])
    # ap data
  end

  puts "\n"
  puts "Inserted #{col.count()} values into #{col.name}"
  puts "\n"
end

puts "\n"
# https://www.pathofexile.com/character-window/get-items?accountName=K41C&character=tcKwz
