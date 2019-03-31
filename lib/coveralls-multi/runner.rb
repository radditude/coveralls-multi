require 'json'
require 'coveralls'

module CoverallsMulti
  class Runner
    attr_accessor :files

    def initialize
      @files = CoverallsMulti::Config.files
    end

    def start
      payload = merge
      write_to_file(payload)
      puts '[CoverallsMulti] Validating payload'
      valid = CoverallsMulti::Validator.new(payload).run
      CoverallsMulti::API.post_json(payload) if valid
    end

    # TODO: make this happen in the api class so it can write the full config and everything
    def write_to_file(payload)
      return unless CoverallsMulti::Config.debug_mode

      output_file_path = "#{CoverallsMulti::Config.root}/coveralls.json"
      puts "[CoverallsMulti] Debug mode on - writing results to #{output_file_path}"
      File.write(output_file_path, JSON.pretty_generate(payload))
    end

    def merge
      source_files = format_all_coverage_files
      merged = { 'source_files' => source_files }
      CoverallsMulti::Formatter.add_source_digests(merged)

      puts '[CoverallsMulti] All coverage files merged and formatted'
      merged
    end

    def format_all_coverage_files
      type_array = @files.keys
      formatted_array = []

      type_array.each do |type|
        result = formatter(type).new.run(@files[type])
        formatted_array.concat result
      end

      formatted_array
    end

    def formatter(string)
      string_klass = "CoverallsMulti::Formatter::#{string.capitalize}"
      Object.const_get(string_klass)
    rescue NameError => e
      puts "[CoverallsMulti] Could not find formatter #{string_klass}"
      raise e
    end
  end
end
