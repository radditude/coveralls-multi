require 'json'
require 'httparty'
require 'tempfile'

module CoverallsMulti
  # handles the post request to the Coveralls API
  class API
    # TODO: move this all into the actual config class and test it
    if ENV['COVERALLS_ENDPOINT']
      API_HOST = ENV['COVERALLS_ENDPOINT']
      API_DOMAIN = ENV['COVERALLS_ENDPOINT']
    else
      API_HOST = ENV['COVERALLS_DEVELOPMENT'] ? 'localhost:3000' : 'coveralls.io'
      API_PROTOCOL = ENV['COVERALLS_DEVELOPMENT'] ? 'http' : 'https'
      API_DOMAIN = "#{API_PROTOCOL}://#{API_HOST}".freeze
    end

    API_BASE = "#{API_DOMAIN}/api/v1".freeze

    def self.post_json(endpoint, hash)
      # disable_net_blockers!

      puts JSON.pretty_generate(hash).to_s if ENV['COVERALLS_DEBUG']
      puts "[CoverallsMulti] Submitting to #{API_BASE}"

      url = endpoint_to_url(endpoint)
      hash = apified_hash(hash)

      response = HTTParty.post(
        url,
        body: {
          json_file: hash_to_file(hash),
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

    def self.endpoint_to_url(endpoint)
      "#{API_BASE}/#{endpoint}"
    end

    def self.hash_to_file(hash)
      file = nil
      Tempfile.open(['coveralls-upload', 'json']) do |f|
        f.write(hash.to_json)
        file = f
      end
      File.new(file.path, 'rb')
    end

    def self.apified_hash(hash)
      # TODO: figure out config
      config = Coveralls::Configuration.configuration
      if ENV['COVERALLS_DEBUG'] || Coveralls.testing
        puts '[CoverallsMulti] Submitting with config:'
        output = JSON.pretty_generate(config).gsub(/"repo_token": ?"(.*?)"/, '"repo_token": "[secure]"')
        puts output
      end
      hash.merge(config)
    end
  end
end
