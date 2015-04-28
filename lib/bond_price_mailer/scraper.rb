require 'open-uri'
require 'rexml/document'
require 'pry'

module BondPriceMailer
  Paper = Struct.new(:isin, :name, :close_price, :open_price,
                     :high_price, :low_price, :average_price, :link, :date) do
    def short
      "#{name}: #{price}"
    end

    def long
      "Navn: <a href='#{link}'>#{name}</a>\n" \
      "ISIN: #{isin}\n" \
      "Luk : #{close_price}\n" \
      "Åbn : #{open_price}\n" \
      "Gnms: #{average_price}\n" \
      "Høj : #{high_price}\n" \
      "Lav : #{low_price}\n" \
      "Dato: #{date_formatted}\n"
    end

    def date_formatted
      date.strftime('%d/%m-%Y')
    end

    def to_s
      "#{short}, #{date_formatted}"
    end
  end

  class Scraper
    def self.papers(instruments)
      doc = bonds(instruments)
      binding.pry
      instruments.map do |instrument|
        paper = REXML::XPath.first(doc, "inst[id/text() = '#{instrument}']")
        Paper.new(
          REXML::XPath.first(paper, './isin/text()').to_s,    # isin
          REXML::XPath.first(paper, './nm/text()').to_s,      # name
          REXML::XPath.first(paper, './cp/text()').to_s.to_f, # close_price
          REXML::XPath.first(paper, './op/text()').to_s.to_f, # open_price
          REXML::XPath.first(paper, './hp/text()').to_s.to_f, # high_price
          REXML::XPath.first(paper, './lp/text()').to_s.to_f, # low_price
          "http://www.nasdaqomxnordic.com/bonds/denmark/microsite?Instrument=#{instrument}",
          Date.today
        )
      end
    end

    USER_AGENT = "Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0"
    def self.bonds(instruments)
      inst_ids = instruments.map { |i| i.strip }.join(",")
      uri = URI.parse "http://www.nasdaqomxnordic.com/webproxy/DataFeedProxy.aspx?SubSystem=Prices&Action=GetInstrument&Instrument=#{inst_ids}"
      REXML::Document.new(uri.open("User-Agent" => USER_AGENT).read.to_s).root
    end
  end
end
