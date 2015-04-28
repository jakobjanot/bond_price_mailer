# encoding: UTF-8

require 'open-uri'
require 'rexml/document'
require 'pry'

module BondPriceMailer
  Paper = Struct.new(:isin, :name, :close_price, :open_price,
                     :high_price, :low_price, :average_price, :link, :date) do
    def short
      "#{name}: #{close_price}"
    end

    def long
      "Navn: #{name}\n" \
      "ISIN: #{isin}\n" \
      "Luk : #{close_price}\n" \
      "Åbn : #{open_price}\n" \
      "Gnms: #{average_price}\n" \
      "Høj : #{high_price}\n" \
      "Lav : #{low_price}\n" \
      "Dato: #{date_formatted}\n" \
      "Link: #{link}\n"
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
      papers = []
      REXML::XPath.each(bonds(instruments), './/inst') do |inst|
        id = inst.attributes['id']
        papers << Paper.new(
          *(inst.attributes.values_at('isin', 'nm', 'cp', 'op', 'av', 'hp', 'lp')),
          "http://www.nasdaqomxnordic.com/bonds/denmark/microsite?Instrument=#{id}",
          Date.today
        )
      end
      papers
    end

    USER_AGENT = 'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0'
    def self.bonds(instruments)
      inst_ids = instruments.map(&:strip).join(',')
      uri = URI.parse "http://www.nasdaqomxnordic.com/webproxy/DataFeedProxy.aspx?SubSystem=Prices&Action=GetInstrument&Instrument=#{inst_ids}"
      REXML::Document.new(uri.open('User-Agent' => USER_AGENT).read.to_s).root
    end
  end
end
