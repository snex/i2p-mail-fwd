require_relative 'fetcher'
require_relative 'forwarder'

class I2PMail
  def self.run
    Fetcher.new.fetch
    Forwarder.new.forward
  end
end
