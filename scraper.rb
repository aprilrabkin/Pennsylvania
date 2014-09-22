require 'mechanize'
require "rest_client"
require 'pry-nav'
require 'nokogiri'
require 'csv'

class Scraper 
	attr_reader :ids, :table, :rows
	def initialize
		@rows = []
	end

	def scrape_each_county_page
		i = 1	
		while i < 159 do #The last one is Worth County
			agent = Mechanize.new 
			page = agent.get("http://sos.ga.gov/cgi-bin/countyregistrarsindex.asp")
			form = page.forms[1]
			form.field_with(:name=>"CountyName").options[i].click
#			form.submit
						binding.pry
#			@table = form.submit.parser.css('.subBody elections')

			i += 1
			parse_county
		end
	end

	def parse_county
		if @table.children[0].text.include?("County County")
			names = @table.children[0].text.gsub!("County County", "County, County").split!(",") #works for everything except Kansas and2 St Louis
			county = names[0]
			office = names[1]
		else 
			county = @table.children[0].text
		end
		phone = @table.children[6].text
		if @table.children.attribute('href').text != ""
			website = @table.children.attribute('href').text
		end
		@rows << [county, office, phone, website ? website : nil].flatten
	end

	def write_into_CSV_file
		CSV.open("spreadsheet.csv", "wb") do |csv|
			@rows.map do |line|
				csv << line
			end
		end
	end

end

a = Scraper.new
a.scrape_each_county_page
a.write_into_CSV_file
