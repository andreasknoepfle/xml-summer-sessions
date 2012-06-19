

class SearchTracksController < ApplicationController
  def search

  end
  def list
    session = BaseXClient::Session.new("84.200.15.101", 1984, "admin", "admin")
    
    # perform command and print returned string
    @result =  session.execute("open tracks_raw")
      
    @result =  session.execute("xquery for $track in //tracks/track
                                where contains($track/title, 'Berlin')
                                order by $track/title
                                return $track")
    #end

    # close session
    session.close
    rescue
  end
  def show
     @pois = Poi.find(52.514967298868314, 13.464775085449219, 0.01) 
     map = GoogleStaticMap.new :width => 700, :height => 700,:maptype => "satellite"
     count=1
     @pois_xml = []
     @pois.each do |poi| 
        @pois_xml << poi.to_xml(:root => "poi")
        map.markers << MapMarker.new(:color => "blue", :label => count.to_s ,:location => MapLocation.new(:latitude => poi[:lat], :longitude => poi[:long]))
        count+=1
      end
     
    poly = MapPolygon.new(:color => "0x00FF00")
    poly.points << MapLocation.new(:latitude => 52.514967298868314, :longitude => 13.464775085449219)
    poly.points << MapLocation.new(:latitude => 52.544967298868314, :longitude => 13.474775085449219)
    poly.points << MapLocation.new(:latitude => 52.554967298868314, :longitude => 13.484775085449219)
    map.paths << poly
     @image = map.url(:auto)
  end
  
  
end
