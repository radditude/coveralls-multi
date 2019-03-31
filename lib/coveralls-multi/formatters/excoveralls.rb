require 'json'
require 'pathname'

module CoverallsMulti
  class Formatter
    # formats excoveralls JSON output files
    # before merge + push to Coveralls
    class Excoveralls
      def run(file_path)
        file = CoverallsMulti::Formatter.parse_json(file_path)
        # ExCoveralls uses paths relative to the elixir app root, which breaks things
        # if the elixir app is in a subdirectory of the repo as a whole.
        # So, for a somewhat hacky solution, we grab the subdirectory if it exists
        # based on the path of the coverage file...
        subdirectory = file_path.split('cover')[0]
        source_files = file['source_files'].map do |source_file|
          path = source_file['name']
          # ...and prepend it to the file path before sending things off to Coveralls.
          source_file['name'] = subdirectory + path
          source_file
        end
        source_files
      rescue StandardError => e
        puts "[CoverallsMulti] There was a problem converting the excoveralls file at #{file_path}."
        puts '[CoverallsMulti] Make sure the file exists.'
        raise e
      end
    end
  end
end
