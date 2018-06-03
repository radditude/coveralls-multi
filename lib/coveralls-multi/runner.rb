require 'json'

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
    end
  end
end
