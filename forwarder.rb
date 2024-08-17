require 'base64'
require 'gpgme'
require 'net/smtp'
require 'yaml'

require_relative 'util'

class Forwarder
  def initialize
    config = YAML.load(File.readlines('config/config.yaml').join)
    @host = config['smtp']['host'] || '127.0.0.1'
    @port = config['smtp']['port'] || 25
    @use_ssl = config['smtp']['ssl']
    @username = config['smtp']['username']
    @password = config['smtp']['password']
    @times_per_day = config['smtp']['times_per_day'] || 1
    @gpg_recipient = config['gpg']['recipient']
    @from = config['smtp']['from']
    @to = config['smtp']['to']
    @subject = config ['smtp']['subject']
  end

  def forward
    return unless Util.should_perform?(@times_per_day)

    smtp = Net::SMTP.new(@host, @port)
    smtp.enable_starttls if @use_ssl
    smtp.start(user: @username, password: @password)
    crypto = GPGME::Crypto.new

    emails = []

    Dir.glob('inbox/*.eml') do |f|
      email = Base64.encode64(crypto.encrypt(File.readlines(f).join, recipients: @gpg_recipient).to_s)
      pgp = <<PGP
-----BEGIN PGP MESSAGE-----
#{email}
-----END PGP MESSAGE-----
PGP
      emails << pgp
    end

    return if emails.empty?

    message = <<END_OF_MESSAGE
From: #{@from}
To: #{@to}
Subject: #{@subject}
Date: #{Time.now}

Number of items: #{emails.size}

=============================================
#{emails.join("\n\n=============================================\n\n")}
END_OF_MESSAGE

    smtp.send_message(message, @from, @to)
    smtp.finish
  end
end
