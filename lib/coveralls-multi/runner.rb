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
      puts 'Validating payload and pushing to Coveralls'
      valid = CoverallsMulti::Validator.new(payload).run
      Coveralls::API.post_json('jobs', payload) if valid
    end

    def write_to_file(payload)
      return unless CoverallsMulti::Config.debug_mode

      output_file_path = "#{CoverallsMulti::Config.root}/coveralls.json"
      puts "Writing results to #{output_file_path}"
      File.write(output_file_path, JSON.pretty_generate(payload))
    end

    def merge
      js_result = formatter('lcov').new.run(@files['lcov'])
      ruby_result = formatter('simplecov').new.run(@files['simplecov'])
      # add Ruby coverage
      source_files = js_result.concat ruby_result
      merged = { 'source_files' => source_files }
      # create md5 source digests for all files
      CoverallsMulti::Formatter.add_source_digests(merged)
      CoverallsMulti::Formatter.add_travis_keys(merged)
      puts 'All files merged and formatted'
      merged
    end

    def formatter(string)
      string_klass = "CoverallsMulti::Formatter::#{string.capitalize}"
      Object.const_get(string_klass)
    rescue NameError => e
      raise e, "Could not find formatter #{string_klass}"
    end
  end
end
