require 'socket'

module MemcachedInvestigator
  class Client
    attr_accessor :sock

    def initialize(hostname: 'localhost', port: 11211)
      @sock = TCPSocket.new(hostname, port)
    end

    def stats
      sock.write("stats\r\n")
      loop do
        response = sock.readline(chomp: true)
        p response
        break if response.include?('END')
      end
    end
  end
end
