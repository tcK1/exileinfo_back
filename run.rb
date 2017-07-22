require 'net/http'
require 'json'
require 'mongo'
require 'ap'

client = Mongo::Client.new('mongodb://127.0.0.1:27017/exileinfo')

# Select collection, read from the API and insert on the base
collection = client[:accounts]
collection.drop

url = 'http://api.pathofexile.com/ladders/Standard'
uri = URI(url)
response = Net::HTTP.get(uri)
j = JSON.parse(response)
ap j["entries"]

result = collection.insert_many(j["entries"])
ap result.inserted_count
