require 'net/http'
require 'rexml/document'
require 'nokogiri'

class SearchTracksController < ApplicationController
  def search

  end

  def list
    session = BaseXClient::Session.new("84.200.15.101", 1984, "admin", "admin")

    # perform command and print returned string
    session.execute("open tracks_kml")

    query = "xquery let $style := \n"
    query += IO.read(Rails.root.join('xml/tracklist.xslt'))
    query += "\nfor $track in //track "
    query += "where contains($track/title, '"
    query += params[:search_tag]
    query += "') "
    query += "or contains($track/startPointAddress, '"
    query += params[:search_tag]
    query += "') "
    query += "or contains($track/endPointAddress, '"
    query += params[:search_tag]
    query += "') "
    query += "order by $track/title "
    query += "return xslt:transform($track,$style)"

    @result =  session.execute(query)

    # close session
    session.close

  end

  def show
    # 
    session = BaseXClient::Session.new("84.200.15.101", 1984, "admin", "admin")
    session.execute("open tracks_kml")
    @result = session.execute("xquery db:open(\"tracks_kml\", \""+params[:q]+"\")")

    track_tmp = Hash.from_xml @result
    @track=track_tmp["track"]
   
    coordinates_string = @track["coordinates"].split(" ")
    @coordinates = []
    coordinates_string.each do |entry|
      latlong = entry.split ","
      @coordinates << {:latitude => latlong[1].to_f ,:longitude => latlong[0].to_f} 
    end
   
    
    count=0
    coordinates_poi = []
    @coordinates.each do |coordinate|
     
      if count.modulo(10) ==0
         coordinates_poi << coordinate
      end
      count+=1
    end
    if(@track.has_key? "pois")
      @pois=@track["pois"]["poi"]
    else  
      @pois = Poi.find(coordinates_poi, 0.01)

      @track["pois"] = @pois
      track_xml = @track.to_xml :root => "track", :skip_types => true

      # Schemavalidierung
      xsd = Nokogiri::XML::Schema(open('xml/schema.xsd'))
      if(xsd.valid?(Nokogiri::XML(track_xml)))
      	session.replace(params[:q],track_xml)
      end
    end
   
    map = GoogleStaticMap.new :width => 500, :height => 500
    map_sat = GoogleStaticMap.new :width => 500, :height => 500,:maptype => "satellite"
    
    count=0
    @letters= []
     (1..9).each do |l|
      @letters << l.to_s
    end
    ('A'..'Z').each do |l|
      @letters << l
    end

    @pois.each do |poi|
      tweets=Twitter.search(poi["label"],:rpp => 5)
      if tweets
        poi["tweets"]=tweets
      end
      map.markers << MapMarker.new(:color => "blue", :label => @letters[count] ,:location => MapLocation.new(:latitude => poi["lat"], :longitude => poi["long"]))
      map_sat.markers << MapMarker.new(:color => "blue", :label =>  @letters[count] ,:location => MapLocation.new(:latitude => poi["lat"], :longitude => poi["long"]))
      count+=1
    end

    poly = MapPolygon.new(:color => "0x00FF00")
    coordinates_poi.each do |coordinate|
      poly.points << MapLocation.new(:latitude => coordinate[:latitude], :longitude => coordinate[:longitude])
    end
    map.paths << poly
    map_sat.paths << poly
    @image = map.url(:auto)
    @image_sat = map_sat.url(:auto)
   
  end

end
