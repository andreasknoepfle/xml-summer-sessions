


class Poi < Hash
  def self.find latitude, longitude, radius
    query = "PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
	    PREFIX dbo: <http://dbpedia.org/ontology/>
	    SELECT ?s ?lat ?long WHERE {
	    ?s geo:lat ?lat .
	    ?s geo:long ?long .

	    FILTER (
	    ?long > #{longitude-radius} &&
	    ?long < #{longitude+radius} &&
	    ?lat > #{latitude-radius} &&
	    ?lat < #{latitude+radius})
	    }
	    LIMIT 100"
    print query
    result = {}
    client = SPARQL::Client.new("http://dbpedia.org/sparql")
    query_res = client.query(query)
    result_list = []
    query_res.each_solution do |solution|
      query = "SELECT  ?label ?abstract ?thumb
	                 WHERE {
	                    <#{solution[:s]}> rdfs:label ?label.
	                    <#{solution[:s]}> <http://dbpedia.org/ontology/abstract> ?abstract.
	                    <#{solution[:s]}> dbpedia-owl:thumbnail ?thumb

	                FILTER (langMatches( lang(?label), \'de\') && langMatches( lang(?abstract), \'de\')) }"

      result = client.query(query)
      result.each_solution do |innersolution|
        poi = Poi.new
        poi[:lat] = solution[:lat]
        poi[:long] = solution[:long]
        poi[:label] = innersolution[:label].to_s
        poi[:abstract] = innersolution[:abstract].to_s
        poi[:thumb] = innersolution[:thumb]
        print poi
        result_list.push poi
      end
    end
    
    result_list
  end
end