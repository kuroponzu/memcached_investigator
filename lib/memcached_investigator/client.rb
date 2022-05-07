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

    def socket_write(args)
      sock.write(args)
    end

    def socket_readline
      sock.readline(chomp: true)
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
      sock.readline(chomp: true)
    end

    def add(key:, value:, **option)
      flag = option[:flag] || 0
      expire = option[:expire] || (Time.now.to_i + 3600)
      size = value.bytesize
      sock.write("add #{key} #{flag} #{expire} #{size} \r\n#{value}\r\n")
      sock.readline(chomp: true)
    end

    def replace(key:, value:, **option)
      flag = option[:flag] || 0
      expire = option[:expire] || (Time.now.to_i + 3600)
      size = value.bytesize
      sock.write("replace #{key} #{flag} #{expire} #{size} \r\n#{value}\r\n")
      sock.readline(chomp: true)
    end

    def append(key:, size:, **option)
      flag = option[:flag] || 0
      expire = option[:expire] || (Time.now.to_i + 3600)
      size = value.bytesize
      sock.write("append #{key} #{flag} #{expire} #{size} \r\n#{value}\r\n")
      sock.readline(chomp: true)
    end

    def prepend(key:, size:, **option)
      flag = option[:flag] || 0
      expire = option[:expire] || (Time.now.to_i + 3600)
      size = value.bytesize
      sock.write("prepend #{key} #{flag} #{expire} #{size} \r\n#{value}\r\n")
      sock.readline(chomp: true)
    end

    def delete(key:)
      sock.write("delete #{key}\r\n")
      sock.readline(chomp: true)
    end

    def flush_all
      sock.write("flush_all\r\n")
      sock.readline(chomp: true)
    end

    def metadump_all
      if "1.4.34" < memcached_version
        sock.write("lru_crawler metadump all\r\n")
        display_response
      else
        "Not support metadump for this version"
      end
    end

    def import(csv_file:)
      if File.file?(csv_file)
        table = CSV.read(csv_file, headers: true)
        table.each do |row|
          set(key: row['key'], value: row['value'], **row.to_h)
        end
      else
        "File is not found #{csv_file}"
      end
    end

    def export_metadump_all
      export_data = []
      sock.write("lru_crawler metadump all\r\n")
      loop do
        response = sock.readline(chomp: true)
        break if response.include?('END')
        # Note
        # ❯ echo 'lru_crawler metadump all' | nc localhost 11211
        # key=test exp=1651829132 la=1651786446 cas=13 fetch=yes cls=1 size=71
        array_response = response.sub(/key=/,'').sub(/exp=/,'').sub(/la=/,'').sub(/cas=/,'').sub(/fetch=/,'').sub(/cls=/,'').sub(/size=/,'').split(' ')
        export_data << array_response
      end
      CSV.open('metadump.csv','wb') do |csv|
        csv << ['key','exp','la','cas','fetch','cls','size']
        export_data.each do |ed|
          csv << ed
        end
      end
    end

    def delete_never_expires_data
      never_expires_data_keys = []
      sock.write("lru_crawler metadump all\r\n")
      loop do
        response = sock.readline(chomp: true)
        break if response.include?('END')
        # Note
        # ❯ echo 'lru_crawler metadump all' | nc localhost 11211
        # key=test exp=1651829132 la=1651786446 cas=13 fetch=yes cls=1 size=71
        array_response = response.split(' ')
        if 1 > array_response[1].sub(/exp=/,'').to_i
          never_expires_data_keys << array_response[0].sub(/key=/,'')
        end
      end
      never_expires_data_keys.each do |never_expires_data_key|
        delete(key: never_expires_data_key)
      end
    end

    def memcached_version
      socket_write("version\r\n")
      response = socket_readline
      response.delete("VERSION").strip
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
