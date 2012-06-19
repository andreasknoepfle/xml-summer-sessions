
require 'net/http'
require 'rexml/document'

class SearchTracksController < ApplicationController
  def search

  end
  def list
    session = BaseXClient::Session.new("84.200.15.101", 1984, "admin", "admin")
    
    # perform command and print returned string
    @result =  session.execute("open tracks_kml")
      
    query = "xquery for $track in //track
                                where contains($track/title, '" + params[:search_tag] + "') " +
                                "or contains($track/startPointAddress, '" + params[:search_tag] + "') " +
                                "or contains($track/endPointAddress, '"+ params[:search_tag] + "') " +
                                "order by $track/title
                                return $track"

    @result =  session.execute(query)

    # close session
    session.close
   
  end
  
  def show
     @coordinates = [{:latitude => 52.514967298868314, :longitude => 13.464775085449219},{:latitude => 52.544967298868314, :longitude => 13.474775085449219},{:latitude => 52.554967298868314, :longitude => 13.484775085449219}]
     @pois = Poi.find(@coordinates, 0.01) 
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
    @coordinates.each do |coordinate|
      poly.points << MapLocation.new(:latitude => coordinate[:latitude], :longitude => coordinate[:longitude])
    end
    map.paths << poly
    map_sat.paths << poly
    @image = map.url(:auto)
    @image_sat = map_sat.url(:auto)
  end
  
  
end
