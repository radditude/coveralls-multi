module CoverallsMulti
  class Formatter
    # formats SimpleCov coverage results files
    # before merge + push to Coveralls
    class Simplecov

      # helper to grab the filename relative to the repo root
      def format_short_filename(filename)
        filename = filename.gsub(CoverallsMulti::Config.root, '.').gsub(/^\.\//, '') if CoverallsMulti::Config.root
        filename
      end

      # get relevant data from the Ruby coverage report & format it
      def run(file_path)
        file = CoverallsMulti::Formatter.parse_json(file_path)

        source_files = []
        begin
          file.keys.each do |test_suite_key|
            file[test_suite_key]['coverage'].each do |filename, coverage|
              properties = {}

              properties['source'] = File.open(filename, 'rb:utf-8').read
              properties['name'] = format_short_filename(filename)
              properties['coverage'] = coverage

              source_files << properties
            end
          end
        rescue StandardError => e
          raise e, "There was a problem formatting the simplecov report at #{file_path}"
        end

        puts 'SimpleCov report reformatted to prepare for merge'
        source_files
      end
    end
  end
end
