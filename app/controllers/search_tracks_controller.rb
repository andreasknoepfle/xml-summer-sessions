require 'net/http'
require 'rexml/document'

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
    @result = session.execute("xquery for $track in //track where $track/fileId = \"" +params[:q]+"\" return $track")
    puts 
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
    
    @pois = Poi.find(coordinates_poi, 0.01)
    map = GoogleStaticMap.new :width => 500, :height => 500
    map_sat = GoogleStaticMap.new :width => 500, :height => 500,:maptype => "satellite"
    
    
    count=1
    @pois_xml = []
    @pois.each do |poi|
      @pois_xml << poi.to_xml(:root => "poi")
      map.markers << MapMarker.new(:color => "blue", :label => count.to_s ,:location => MapLocation.new(:latitude => poi[:lat], :longitude => poi[:long]))
      map_sat.markers << MapMarker.new(:color => "blue", :label => count.to_s ,:location => MapLocation.new(:latitude => poi[:lat], :longitude => poi[:long]))
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
