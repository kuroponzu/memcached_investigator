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

    def get(key)
      sock.write("get #{key}\r\n")
      loop do
        response = sock.readline(chomp: true)
        p response
        break if response.include?('END')
      end
    end

    def gets(key)
      sock.write("get #{key}\r\n")
      loop do
        response = sock.readline(chomp: true)
        p response
        break if response.include?('END')
      end
    end

    def set(key:, value:, **option)
      flag = option[:flag] || 0
      expire = option[:expire] || (Time.now.to_i + 3600)
      size = value.bytesize
      sock.write("set #{key} #{flag} #{expire} #{size} \r\n#{value}\r\n")
      response = sock.readline(chomp: true)
      p response
    end
  end
end
