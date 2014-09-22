require 'mechanize'
require "rest_client"
require 'pry-nav'
require 'nokogiri'
require 'csv'

class Scraper 
	attr_reader :ids, :table, :rows

	def scrape_each_county_page
		#i = 1	
		#while i < 118 do 
			agent = Mechanize.new
			page = agent.get("http://www.sos.mo.gov/elections/goVoteMissouri/pickupmail.aspx")
			form = agent.page.forms[1]
			form.field_with(:name=>"electioncounty").options[0].select
			@table = form.submit.parser.css('#resultset').children[0]
			binding.pry
			parse_county
			binding.pry

#			i += 1
#			sleep (10)
#		end
	end

	def parse_county
		name = @table.children[0].text
		phone = @table.children[6].text
		if @table.children[10].text != "Website: "
			website = @table.children[10].text
		end
		@rows << [name, phone, website + "\n"]
		binding.pry
	end

	def write_into_CSV_file
binding.pry
		CSV.open("spreadsheet.csv", "wb") do |csv|
			csv << @rows
		end
	end

end

a = Scraper.new
a.scrape_each_county_page
a.write_into_CSV_file
