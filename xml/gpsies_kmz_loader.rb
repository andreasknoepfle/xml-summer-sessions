#!/usr/bin/ruby

# 1. holen aller Tracks
# 2. laden der KMZ Datei
# 3. entpacken der KMZ Datei -> doc.kml
# 4. extrahieren der coordinaten aus der doc.kml
# 5. coordinaten in den Track einfuegen
# 6. Modifizierten Track in neue DB speichern

require '../lib/BaseXClient.rb'
require 'nokogiri'
require 'uri'
require 'net/http'
require 'zip/zip' #gem install rubyzip

begin
	session = BaseXClient::Session.new("84.200.15.101", 1984, "admin", "admin")
	session.execute('open tracks_raw_test')
	
	kml_session = BaseXClient::Session.new("84.200.15.101", 1984, "admin", "admin")
	kml_session.execute('drop db tracks_kml')	
	kml_session.execute('create db tracks_kml')
	
	# 1. holen aller Tracks
	# TODO holt nur die Tracks aus dem 1. Dokument,
	# es werden aber alle benoetigt!
	query = session.query('//track')

	while query.more do

		track = Nokogiri::XML(query.next)
		link = track.at_xpath('//downloadLink').content			
		#puts link
		# 2. laden der KMZ Datei
		`wget #{link} -O tmp/tmp.kmz`

		# 3. entpacken der KMZ Datei -> doc.kml
		Zip::ZipFile.open('tmp/tmp.kmz') {
			|zipfile|
			zipfile.each do |entry|
    			#next if entry.name =~ 'doc.kml'
				# 4. extrahieren der coordinaten aus der doc.kml
				doc = Nokogiri::XML(entry.get_input_stream.read)
				doc.remove_namespaces!
				coordinates = doc.at_xpath('//coordinates')

				# 5. coordinaten in den Track einfuegen
				track.children.first.add_child(coordinates)

				fileId = track.at_xpath('//fileId').content
				kml_session.add(fileId, track.to_s) 
				
			end
		}
    end

	session.close
	kml_session.close

rescue Exception => e
  puts e
end

