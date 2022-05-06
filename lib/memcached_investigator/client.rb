require 'socket'
require "csv"

module MemcachedInvestigator
  class Client
    attr_accessor :sock

    ENABLE_STATS_ARGS = [
      'settings', 'items', 'slabs', 'sizes','detail on',
      'detail off','detail dump','cachedump','conns','exstore','reset'
    ].freeze

    def initialize(hostname: 'localhost', port: 11211)
      @sock = TCPSocket.new(hostname, port)
    end

    def stats(args: "")
      if args == "" || ENABLE_STATS_ARGS.include?(args)
        sock.write("stats #{args}\r\n")
        display_response
      else
        p "Invalid argments. Enable argments #{ENABLE_STATS_ARGS}"
      end
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

    def import(csv_file:)
      if File.file?(csv_file)
        table = CSV.read(csv_file, headers: true)
        table.each do |row|
          set(key: row['key'], value: row['value'], **row.to_h)
        end
      else
        p "File is not found #{csv_file}"
      end
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
