require 'logger'

require_relative 'bond_price_mailer/version'
require_relative 'bond_price_mailer/mail'
require_relative 'bond_price_mailer/scraper'

module BondPriceMailer
  def self.run(receivers_emails, isins)
    papers = Scraper.papers(isins)
    log papers.map(&:to_s)

    receivers_emails.each do |email|
      Mail.deliver do
        to email
        from ENV['EMAIL_FROM'] || ENV['GMAIL_USERNAME']
        subject "[KURS] #{papers.map(&:short).join(', ')}"
        body "#{papers.map(&:long).join("\n\n")}"
      end
    end
  end

  def self.log(msg)
    log_file = ENV['LOG_FILE']
    return unless log_file
    File.open(log_file, 'a') { |f| f.puts msg }
  end
end
