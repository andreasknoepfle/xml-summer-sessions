


class Poi < Hash
  
  def self.find latitude, longitude, radius
    query = "PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
	    PREFIX dbo: <http://dbpedia.org/ontology/>
	    SELECT ?s ?lat ?long ?label ?abstract ?thumb WHERE {
  	    ?s geo:lat ?lat .
  	    ?s geo:long ?long .
        ?s rdfs:label ?label.
        ?s <http://dbpedia.org/ontology/abstract> ?abstract.
        ?s dbpedia-owl:thumbnail ?thumb
  	    FILTER (
    	    ?long > #{longitude-radius} &&
    	    ?long < #{longitude+radius} &&
    	    ?lat > #{latitude-radius} &&
    	    ?lat < #{latitude+radius} &&
    	    langMatches( lang(?label), \'de\') && 
    	    langMatches( lang(?abstract), \'de\')
  	    )
	    }
	    LIMIT 100"
    client = SPARQL::Client.new("http://dbpedia.org/sparql")
    query_res = client.query(query)
    result_list = []
    query_res.each_solution do |solution|
        poi = Poi.new
        poi[:lat] = solution[:lat].value
        poi[:long] = solution[:long].value
        poi[:label] = solution[:label].value
        poi[:abstract] = solution[:abstract].value
        poi[:thumb] = solution[:thumb]
        result_list.push poi
    end
    
    result_list
  end
end