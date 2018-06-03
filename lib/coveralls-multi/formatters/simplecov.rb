module CoverallsMulti
  class Formatter
    # formats SimpleCov coverage results files
    # before merge + push to Coveralls
    class SimpleCov

      # helper to grab the non-absolute filename from simplecov results
      def format_short_filename(filename)
        filename = filename.gsub(CoverallsMulti::Config.root, '.').gsub(/^\.\//, '') if CoverallsMulti::Config.root
        filename
      end

      # get relevant data from the Ruby coverage report & format it
      def run(simple_cov)
        source_files = []
        simple_cov['RSpec']['coverage'].each do |filename, coverage|
          properties = {}

          # Get Source
          properties['source'] = File.open(filename, 'rb:utf-8').read

          # Get the filename relative to the repo root
          properties['name'] = format_short_filename(filename)

          # Get the coverage
          properties['coverage'] = coverage

          source_files << properties
        end
        puts 'SimpleCov report reformatted to prepare for merge'
        source_files
      end
    end
  end
end
