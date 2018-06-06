require 'digest/md5'
require 'json'

# require individual formatters here
require 'coveralls-multi/formatters/excoveralls'
require 'coveralls-multi/formatters/lcov'
require 'coveralls-multi/formatters/simplecov'

module CoverallsMulti
  # contains formatters for individual language/output types
  # and common methods
  class Formatter
    class << self
      def add_source_digests(merged_files)
        merged_files['source_files'].map do |src_file|
          file_content = src_file['source']
          src_digest = Digest::MD5.hexdigest(file_content)
          src_file['source_digest'] = src_digest
          src_file
        end
        puts 'Added source digests'
        merged_files
      end

      def parse_json(path)
        JSON.parse(IO.read("#{CoverallsMulti::Config.root}/#{path}"))
      rescue StandardError => e
        raise e, "Could not parse file at #{path}"
      end
    end
  end
end
