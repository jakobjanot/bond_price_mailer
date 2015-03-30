require 'logger'

require_relative 'bond_price_mailer/version'
require_relative 'bond_price_mailer/mail'
require_relative 'bond_price_mailer/scraper'

module BondPriceMailer
  def self.run(receivers_emails, isins)
    papers = Scraper.papers(isins)
    logger.info papers.map(&:to_s) if logger

    receivers_emails.each do |email|
      Mail.deliver do
        to email
        from ENV['EMAIL_FROM'] || ENV['GMAIL_USERNAME']
        subject "[KURS] #{papers.map(&:short).join(', ')}"
        body "#{papers.map(&:long).join("\n\n")}"
      end
    end
  end

  def self.logger
    @logger ||= begin
      return nil unless ENV['LOG_FILE']
      Logger.new(ENV['LOG_FILE'])
    end
  end
end
