require 'net/http'
require 'json'

url = 'http://api.pathofexile.com/ladders/Standard'
uri = URI(url)
response = Net::HTTP.get(uri)
j = JSON.parse(response)
puts j
