require 'json'
require 'coveralls'

module CoverallsMulti
  class Runner
    attr_accessor :files
    COVERAGE_PATH = 'spec/fixtures'.freeze

    def initialize
      @files = {
        ruby: JSON.parse(IO.read("#{COVERAGE_PATH}/.resultset.json")),
        javascript: JSON.parse(IO.read("#{COVERAGE_PATH}/jscov.json")),
      }
    end

    def start
      puts 'this works'
      payload = unified_payload
      Coveralls::API.post_json('jobs', payload)
    end

    def unified_payload
      payload = CoverallsMulti::Merger.merge(@files)
      write_to_file(payload)
      payload
    end

    def write_to_file(payload)
      File.write("#{COVERAGE_PATH}/coveralls.json", JSON.pretty_generate(payload))
    end
  end
end
