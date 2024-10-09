require 'net/pop'
require 'yaml'

require_relative 'util'

class Fetcher
  def initialize
    config = YAML.load(File.readlines('config/config.yaml').join)
    @host = config['i2p']['host'] || '127.0.0.1'
    @port = config['i2p']['port'] || 7660
    @accounts = config['accounts']
  end

  def fetch
    pop = Net::POP3.new(@host, @port)

    @accounts.each do |account|
      username = account['username']
      password = account['password']
      times_per_day = account['times_per_day']
      retries = account['retries']

      next unless Util.should_perform?(times_per_day)

      begin
        num_tries = 1
        pop.start(username, password)

        if pop.mails.empty?
          next
        else
          i = Dir.glob('inbox/*.eml').size

          pop.each_mail do |m|
            File.open("inbox/#{i}.eml", 'w') do |f|
              f.write m.pop
            end
            m.delete
            i += 1
          end
        end

        pop.finish
      rescue Net::ReadTimeout
        num_tries += 1
        retry if num_tries < retries
      end
    end
  end
end
