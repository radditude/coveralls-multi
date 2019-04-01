require 'json'
require 'httparty'
require 'tempfile'

module CoverallsMulti
  # handles the post request to the Coveralls API
  class API
    class << self
      def post_json(hash)
        url = CoverallsMulti::Config.api_endpoint
        puts "[CoverallsMulti] Submitting to #{url}"

        response = HTTParty.post(
          url,
          body: {
            json_file: json_file(hash),
          },
        )

        puts "[CoverallsMulti] #{response['message']}" if response['message']
        puts "[CoverallsMulti] #{response['url']}" if response['url']
        puts "[CoverallsMulti] Error: #{response['error']}" if response['error']

        response
      end

      def json_file(hash)
        hash = add_api_config(hash)
        write_to_file(hash)
        file = nil

        Tempfile.open(['coveralls-upload', 'json']) do |f|
          f.write(hash.to_json)
          file = f
        end

        File.new(file.path, 'rb')
      end

      def write_to_file(hash)
        return unless CoverallsMulti::Config.debug_mode

        output_file_path = "#{CoverallsMulti::Config.root}/coveralls.json"
        puts "[CoverallsMulti] Debug mode on - writing results to #{output_file_path}"
        File.write(output_file_path, JSON.pretty_generate(hash))
      end

      def add_api_config(hash)
        config = CoverallsMulti::Config.api_config

        if CoverallsMulti::Config.debug_mode
          puts '[CoverallsMulti] Submitting with config:'
          output = JSON.pretty_generate(config).gsub(/"repo_token": ?"(.*?)"/, '"repo_token": "[secure]"')
          puts output
        end

        hash.merge(config)
      end
    end
  end
end
