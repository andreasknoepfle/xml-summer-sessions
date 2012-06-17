require 'nokogiri'

begin
  schema = Nokogiri::XML::Schema(File.read('schema.xsd'))
rescue Nokogiri::XML::SyntaxError => e
  puts "Invalid XML Schema!"
end
