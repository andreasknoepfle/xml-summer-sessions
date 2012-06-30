#!/usr/bin/ruby

# 1. holen aller Tracks
# 2. holen der Addresse des jeweiligen Tracks
# 3. laden der KMZ Datei
# 4. entpacken der KMZ Datei -> doc.kml
# 5. extrahieren der coordinaten aus der doc.kml
# 6. XSL-Transformation -> ersetzt durch Erstellung eines neuen XML
# (7. mit Schema validieren)
# 8. Modifizierten Track in neue DB speichern

require '../lib/BaseXClient.rb'
require 'nokogiri'
require 'uri'
require 'net/http'
require 'zip/zip' #gem install rubyzip

url = 'http://www.gpsies.org/api.do'
key = 'czxpyyinrqaektof'

begin
	session = BaseXClient::Session.new("84.200.15.101", 1984, "admin", "admin")
	session.execute('open tracks_raw')
	
	kml_session = BaseXClient::Session.new("84.200.15.101", 1984, "admin", "admin")
	kml_session.execute('drop db tracks_kml')	
	kml_session.execute('create db tracks_kml')
	kml_session.execute('CREATE INDEX fulltext')
	
	# 1. holen aller Tracks
	query = session.query('//tracks/track')

	while query.more do
		kml_track = Nokogiri::XML
		track = Nokogiri::XML(query.next)
		begin
			link = track.at_xpath('//downloadLink').content
			fileId = track.at_xpath('//fileId').content
		
			# 2. holen der Addresse des jeweiligen Tracks
			track_details = Nokogiri::XML(Net::HTTP.post_form(URI.parse(url), 
				{'key' => key,
		  		 'fileId' => fileId
				}).body)	
		
			startPointAddress = track_details.at_xpath('//startPointAddress').content
			endPointAddress = track_details.at_xpath('//endPointAddress').content				
			countTrackpoints = track_details.at_xpath('//countTrackpoints').content.to_i
			title = track_details.at_xpath('//title').content

			# 3. laden der KMZ Datei
			`wget #{link} -O tmp/tmp.kmz`

			# 4. entpacken der KMZ Datei -> doc.kml
			Zip::ZipFile.open('tmp/tmp.kmz') {
				|zipfile|
				zipfile.each do |entry|
					# TODO
					#next if entry.name =~ 'doc.kml'
					
					# 5. extrahieren der coordinaten aus der doc.kml
					doc = Nokogiri::XML(entry.get_input_stream.read)
					doc.remove_namespaces!
					coordinates = doc.at_xpath('//coordinates').content.split

					# wir brauchen nicht alle koordinaten, daher picken wir uns 50 raus
					incr = countTrackpoints/50
					if incr == 0
						incr = 1
					end

					coordinates_strip = ''

					i = 0
					while i < countTrackpoints
						# altitude wird nicht benoetigt
						coordinates_strip << coordinates[i].split(',')[0] << ',' << coordinates[i].split(',')[1] << ' '
						i += incr
					end

					# 6. XSL-Transformation -> ersetzt durch Erstellung eines neuen XML
					builder = Nokogiri::XML::Builder.new do |xml|
						xml.track {
						  xml.title title
						  xml.fileId fileId
						  xml.startPointAddress startPointAddress
						  xml.endPointAddress endPointAddress
						  xml.coordinates coordinates_strip
						}
					end

					# (7. mit Schema validieren)
					# wird beim Einfuegen der POIs gemacht

					# 8. Modifizierten Track in neue DB speichern
					kml_session.add(fileId, builder.to_xml) 
				
				end
			}
			rescue Exception => e
				puts e
				puts 'naechster track'
				next
			end
    end

	session.close
	kml_session.close

rescue Exception => e
  puts e
end

