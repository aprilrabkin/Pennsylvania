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
		while i < 117 do 
			agent = Mechanize.new
			page = agent.get("http://www.sos.mo.gov/elections/goVoteMissouri/pickupmail.aspx")
			form = agent.page.forms[1]
			form.field_with(:name=>"electioncounty").options[i].click
			@table = form.submit.parser.css('#resultset').children[0]
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
