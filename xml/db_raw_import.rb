#!/usr/bin/ruby

require '../lib/BaseXClient.rb'

begin
	session = BaseXClient::Session.new("84.200.15.101", 1984, "admin", "admin")
	session.execute('open tracks_raw')
	
	Dir[File.dirname(__FILE__) + "/trackfiles/*"].each do |filename|
		file = File.open(filename)
		session.add(filename, file.read)  	
	end  
  
	session.close

rescue Exception => e
  puts e
end

