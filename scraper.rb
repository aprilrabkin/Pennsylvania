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
		i = 0
		while i < 159 do #The last one is Worth County
			agent = Mechanize.new 
			page = agent.get("http://sos.ga.gov/cgi-bin/countyregistrarsindex.asp")
			form = page.forms[1]
			form.field_with(:name=>"CountyName").options[i].click
			button = page.forms[1].buttons[0]
			newpage = agent.submit(form, button)
			@table = newpage.parser.css('.subBody')
			parse_county
			i += 1
		end
	end

	def parse_county
		table = @table.inner_html.gsub(/\n|\r|\t/,'').split('<br>').map do |el| 
			el.split('<hr>') 
		end.flatten
		if table[1]
			if table[1].include?("County")
				county_name = table[1].gsub(/County /,'County, ').split(',')[0]
				office = table[1].gsub(/County /,'County, ').split(',')[1].strip
			end
		end
		phone = (@table.text.scan /Telephone: \(\d*\)\s?\d*-\d*.*/).map do |p| p.gsub(/Telephone: |\n|\r|\t/,'') end
		website = (@table.text.scan /Website: .*/)
		if website
			website.map! do |w| 
				w.gsub('Website: ', '')
			end
		end
		@rows << [county_name, office, phone, website].flatten!	
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
