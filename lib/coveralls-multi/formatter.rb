# require individual formatters here
require 'coveralls-multi/formatters/simplecov'

module CoverallsMulti
  class Formatter
    def add_source_digests(file_array)
      file_array.map do |src_file|
        file_content = src_file['source']
        src_digest = Digest::MD5.hexdigest(file_content)
        src_file['source_digest'] = src_digest
        src_file
      end
      file_array
    end
  end
end
