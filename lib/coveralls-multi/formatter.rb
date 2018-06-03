require 'digest/md5'

# require individual formatters here
require 'coveralls-multi/formatters/simplecov'

module CoverallsMulti

  # contains formatters for individual language/output types
  # and common methods

  # example json output:
  # {
  #   "service_job_id": "1234567890",
  #   "service_name": "travis-pro",
  #   "source_files": [
  #     {
  #       "name": "spec/example.rb",
  #       "source": "the stringified file goes here",
  #       "coverage": [null, 1, null]
  #     },
  #     {
  #       "name": "render-server/some-javascript.js",
  #       "source_digest": "another stringified file",
  #       "coverage": [null, 1, 0, null]
  #     }
  #   ]
  # }
  #
  class Formatter
    def self.add_source_digests(file_array)
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
