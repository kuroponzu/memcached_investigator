# frozen_string_literal: true

require_relative "memcached_investigator/version"
require_relative "memcached_investigator/client"

module MemcachedInvestigator
  class FileNotFoundError < StandardError; end
end
