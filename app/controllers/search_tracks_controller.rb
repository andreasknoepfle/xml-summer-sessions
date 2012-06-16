

class SearchTracksController < ApplicationController
  def search
    session = BaseXClient::Session.new("localhost", 1984, "admin", "admin")

    # perform command and print returned string
    print session.execute("xquery 1 to 10")
  
    # close session
    session.close
    
    
    
  end

  def list
     @pois = Poi.find(52.514967298868314, 13.464775085449219, 0.01) 
     map = GoogleStaticMap.new :width => 700, :height => 700,:maptype => "satellite"
     count=1
     @pois.each do |poi| 
        map.markers << MapMarker.new(:color => "blue", :label => count.to_s ,:location => MapLocation.new(:latitude => poi[:lat], :longitude => poi[:long]))
        count+=1
      end
     
    poly = MapPolygon.new(:color => "0x00FF00FF")
    poly.points << MapLocation.new(:latitude => 52.514967298868314, :longitude => 13.464775085449219)
    poly.points << MapLocation.new(:latitude => 52.544967298868314, :longitude => 13.474775085449219)
    poly.points << MapLocation.new(:latitude => 52.554967298868314, :longitude => 13.484775085449219)
    map.paths << poly
     @image = map.url(:auto)
  end
  
  
end
