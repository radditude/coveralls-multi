require 'json'
require 'coveralls'

module CoverallsMulti
  class Runner
    attr_accessor :files
    COVERAGE_PATH = "#{CoverallsMulti::Config.root}/coverage".freeze

    def initialize
      puts "Parsing files at #{COVERAGE_PATH}"
      @files = {
        ruby: JSON.parse(IO.read("#{COVERAGE_PATH}/.resultset.json")),
        javascript: JSON.parse(IO.read("#{COVERAGE_PATH}/jscov.json")),
      }
    end

    def start
      payload = unified_payload
      puts 'Starting push to Coveralls'
      Coveralls::API.post_json('jobs', payload)
    end

    def unified_payload
      payload = CoverallsMulti::Merger.new.merge(@files)
      write_to_file(payload)
      payload
    end

    def write_to_file(payload)
      output_file_path = "#{COVERAGE_PATH}/coveralls.json"
      puts "Writing results to #{output_file_path}"
      File.write(output_file_path, JSON.pretty_generate(payload))
    end
  end
end
