require 'json'

module CoverallsMulti
  class Formatter
    # formats excoveralls JSON output files
    # before merge + push to Coveralls
    class Excoveralls
      def run(file_path)
        file = CoverallsMulti::Formatter.parse_json(file_path)
        file['source_files']
      rescue StandardError => e
        raise e, "There was a problem converting the excoveralls file at #{file_path}"
      end
    end
  end
end
