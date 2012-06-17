#!/usr/bin/ruby

require 'net/http'
require "uri"

url = 'http://www.gpsies.org/api.do'
key = 'czxpyyinrqaektof'
country = 'DE'
limit = '100'

# get 100*300 = 300.000 tracks

for i in 1..300
	params = {
	  'key' => key,
	  'country' => country,
	  'limit' => limit,
	  'resultPage' => i
	}

	resp = Net::HTTP.post_form(URI.parse(url), params)
	
	File.open('trackfiles/tracks'<<i.to_s<<'.xml', 'w') {|f| f.write(resp.body) }
end
