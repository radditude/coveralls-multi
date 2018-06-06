require 'json'

module CoverallsMulti
  # checks that a payload is valid before sending to Coveralls
  class Validator
    attr_accessor :payload
    TOP_LEVEL_KEYS = %w[source_files].freeze
    SOURCE_FILE_KEYS = %w[name source_digest coverage source].freeze

    def initialize(payload)
      @payload = payload
    end

    def run
      return true if json? && valid_coveralls_payload?
    end

    def json?
      parsed_json = JSON.dump(@payload)
      parsed_json
    rescue JSON::UnparserError => e
      raise e, 'Payload could not be parsed to JSON!'
    end

    def valid_coveralls_payload?
      raise 'Payload is empty!' if !@payload || @payload.empty?
      raise 'Payload should be a hash!' unless @payload.is_a?(Hash)

      check_required_keys(TOP_LEVEL_KEYS, 'Missing required top-level key')
      @payload['source_files'].each do |src_file|
        check_required_keys(
          SOURCE_FILE_KEYS, 'Missing required source file key(s)', src_file
        )
      end
      @payload
    end

    def check_required_keys(required_keys, message = 'Missing required key(s)', payload = @payload)
      missing_keys = []

      required_keys.each do |key|
        missing_keys.push key unless payload[key]
      end

      error = "#{message} - #{missing_keys.join(', ')}"

      raise error unless missing_keys.empty?
    end
  end
end
