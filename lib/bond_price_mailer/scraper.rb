require 'open-uri'
require 'rexml/document'

module BondPriceMailer
  Paper = Struct.new(:isin, :name, :price, :date) do
    def short
      "#{name}: #{price}"
    end

    def long
      "Navn: #{name}\nISIN: #{isin}\nKurs: #{price}\nDato: #{date_formatted}"
    end

    def date_formatted
      date.strftime('%d/%m-%Y')
    end

    def to_s
      "#{short}, #{date_formatted}"
    end
  end

  class Scraper
    def self.papers(isins)
      doc = tier_list

      isins.map do |isin|
        paper = REXML::XPath.first(doc, ".//Papir[isin/text() = '#{isin}']")
        Paper.new(
        REXML::XPath.first(paper, './isin/text()').to_s,
        REXML::XPath.first(paper, './navn/text()').to_s,
        REXML::XPath.first(paper, './kurs/text()').to_s.to_f,
        Date.today
        )
      end
    end

    def self.tier_list
      REXML::Document.new(open('http://dataservice.nationalbanken.dk/data/tierliste/tierlistedkk.xml')).root
    end
  end
end
