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
      # we can use the js result as the foundation for now
      # since it already has service_name and service_job_id thanks to coveralls-lcov
      js_result = CoverallsMulti::Formatter.parse_json(@files['javascript'])
      ruby_result = CoverallsMulti::Formatter::Simplecov.new.run(@files['ruby'])
      # add Ruby coverage
      js_result['source_files'].concat ruby_result
      merged = js_result
      # create md5 source digests for all files
      CoverallsMulti::Formatter.add_source_digests(merged)
      CoverallsMulti::Formatter.add_travis_keys(merged)
      puts 'All files merged and formatted'
      merged
    end
  end
end
