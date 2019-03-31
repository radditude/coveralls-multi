require 'coveralls/lcov/converter'
require 'json'

module CoverallsMulti
  class Formatter
    # formats lcov coverage results files
    # before merge + push to Coveralls
    class Lcov
      # convert lcov files using the coveralls-lcov gem
      def run(file_path)
        converter = Coveralls::Lcov::Converter.new(file_path)
        file = converter.convert
        # HACK: stringify keys without iterating over the whole array of hashes
        JSON.parse(JSON.dump(file[:source_files]))
      rescue StandardError, SystemExit => e
        puts "[CoverallsMulti] There was a problem converting the lcov file at #{file_path}."
        puts '[CoverallsMulti] Make sure the file exists.'
        raise e
      end
    end
  end
end
