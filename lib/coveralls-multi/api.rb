require 'json'
require 'httparty'
require 'tempfile'

module CoverallsMulti
  # handles the post request to the Coveralls API
  class API
    def self.post_json(hash)
      # disable_net_blockers!
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

      # TODO: figure out error handling given httparty
      case response
      when Net::HTTPServiceUnavailable
        puts 'Coveralls API timeout occured, but data should still be processed'
      end
    end

    # TODO: figure out what this is for
    # def self.disable_net_blockers!
    #   begin
    #     require 'webmock'

    #     allow = WebMock::Config.instance.allow || []
    #     WebMock::Config.instance.allow = [*allow].push API_HOST
    #   rescue LoadError
    #   end

    #   begin
    #     require 'vcr'

    #     VCR.send(VCR.version.major < 2 ? :config : :configure) do |c|
    #       c.ignore_hosts API_HOST
    #     end
    #   rescue LoadError
    #   end
    # end

    def self.json_file(hash)
      hash = add_api_config(hash)
      file = nil

      Tempfile.open(['coveralls-upload', 'json']) do |f|
        f.write(hash.to_json)
        file = f
      end

      File.new(file.path, 'rb')
    end

    def self.add_api_config(hash)
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
