require 'socket'

module MemcachedInvestigator
  class Client
    attr_accessor :sock

    def initialize(hostname: 'localhost', port: 11211)
      @sock = TCPSocket.new(hostname, port)
    end

    def stats
      sock.write("stats\r\n")
      display_response
    end

    def stats(args: "")
      sock.write("stats #{args}\r\n")
      display_response
    end

    def get(key:)
      sock.write("get #{key}\r\n")
      display_response
    end

    def gets(key:)
      sock.write("gets #{key}\r\n")
      display_response
    end

    def set(key:, value:, **option)
      flag = option[:flag] || 0
      expire = option[:expire] || (Time.now.to_i + 3600)
      size = value.bytesize
      sock.write("set #{key} #{flag} #{expire} #{size} \r\n#{value}\r\n")
      response = sock.readline(chomp: true)
      p response
    end

    def add(key:, size:, **option)
      flag = option[:flag] || 0
      expire = option[:expire] || (Time.now.to_i + 3600)
      sock.write("set #{key} #{flag} #{expire} #{size}\r\n")
      response = sock.readline(chomp: true)
      p response
    end

    def replace(key:, size:, **option)
      flag = option[:flag] || 0
      expire = option[:expire] || (Time.now.to_i + 3600)
      sock.write("set #{key} #{flag} #{expire} #{size}\r\n")
      response = sock.readline(chomp: true)
      p response
    end

    def append(key:, size:, **option)
      flag = option[:flag] || 0
      expire = option[:expire] || (Time.now.to_i + 3600)
      sock.write("apend #{key} #{flag} #{expire} #{size}\r\n")
      response = sock.readline(chomp: true)
      p response
    end

    def prepend(key:, size:, **option)
      flag = option[:flag] || 0
      expire = option[:expire] || (Time.now.to_i + 3600)
      sock.write("prepend #{key} #{flag} #{expire} #{size}\r\n")
      response = sock.readline(chomp: true)
      p response
    end

    def delete(key:)
      sock.write("delete #{key}\r\n")
      display_response
    end

    def flush_all
      sock.write("flush_all\r\n")
      response = sock.readline(chomp: true)
      p response
    end

    private def display_response
      loop do
        response = sock.readline(chomp: true)
        p response
        break if response.include?('END')
      end
    end
  end
end
