require 'base64'
require 'gpgme'
require 'net/pop'
require 'net/smtp'
require 'yaml'

config = YAML.load(File.readlines('config.yaml').join)

pop = Net::POP3.new(config['i2p']['host'], config['i2p']['port'])
smtp = Net::SMTP.new(config['smtp']['host'], config['smtp']['port'])
smtp.enable_starttls if config['smtp']['ssl']
crypto = GPGME::Crypto.new

config['accounts'].each do |account|
  username = account['username']
  password = account['password']

  pop.start(username, password)

  if pop.mails.empty?
    puts 'No mail.'
  else
    smtp.start(user: config['smtp']['username'], password: config['smtp']['password'])

    pop.each_mail do |m|
      message_to_fwd = Base64.encode64(crypto.encrypt(m.pop, recipients: config['gpg']['recipient']).to_s)
      message = <<END_OF_MESSAGE
From: #{config['smtp']['from']}
To: #{config['smtp']['to']}
Subject: #{config['smtp']['subject']}
Date: #{Time.now}

-----BEGIN PGP MESSAGE-----

#{message_to_fwd}
-----END PGP MESSAGE-----
END_OF_MESSAGE

      smtp.send_message(message, config['smtp']['from'], config['smtp']['to'])
      m.delete
    end

    smtp.finish
    puts "#{pop.mails.size} mails popped."
  end

  pop.finish
end
