RSpec.describe CoverallsMulti::API do
  let(:yml) do
    {
      'multi' => {
        'simplecov' => 'spec/fixtures/.resultset.json',
        'lcov' => 'spec/fixtures/lcov.info',
        'excoveralls' => 'spec/fixtures/excoveralls.json',
      },
    }
  end

  before do
    allow(CoverallsMulti::Config).to receive(:yaml_config).and_return(yml)
    @runner = CoverallsMulti::Runner.new
    @puts_one = '[CoverallsMulti] Added source digests'
    @puts_two = '[CoverallsMulti] All coverage files merged and formatted'
  end

  describe '.post_json' do
    it 'submits to the default endpoint' do
      endpoint = 'https://coveralls.io/api/v1/jobs'
      stub_request(:any, endpoint).to_return(status: 200, body: 'ok')
      expect(STDOUT).to receive(:puts).and_return(
        @puts_one,
        @puts_two,
        "[CoverallsMulti] Submitting to #{endpoint}",
      )

      expect(CoverallsMulti::API.post_json(@runner.merge).body).to eq('ok')
    end

    it 'submits to COVERALLS_ENDPOINT if it is set' do
      endpoint = 'https://fakecoverallsendpoint.tld'
      stub_const('ENV', 'COVERALLS_ENDPOINT' => endpoint)
      stub_request(:any, "#{endpoint}/api/v1/jobs").to_return(status: 200, body: 'ok')
      expect(STDOUT).to receive(:puts).and_return(
        @puts_one,
        @puts_two,
        "[CoverallsMulti] Submitting to #{endpoint}",
      )

      expect(CoverallsMulti::API.post_json(@runner.merge).body).to eq('ok')
    end
  end

  describe '.api_config' do
    it 'outputs the config to stout if debug mode is on' do
      expect(STDOUT).to receive(:puts).and_return(
        @puts_one,
        @puts_two,
        '[CoverallsMulti] Submitting with config:',
        /{.+}/,
      )

      yml = { 'debug_mode' => true }
      allow(CoverallsMulti::Config).to receive(:yaml_config).and_return(yml)
      allow(File).to receive(:write).and_return(true)

      expect(CoverallsMulti::API.add_api_config(@runner.merge)).to be_a(Hash)
    end

    it 'does not output the config if debug mode is off' do
      expect(STDOUT).to receive(:puts).and_return(
        @puts_one,
        @puts_two,
      )

      yml = { }
      allow(CoverallsMulti::Config).to receive(:yaml_config).and_return(yml)
      allow(File).to receive(:write).and_return(true)

      expect(CoverallsMulti::API.add_api_config(@runner.merge)).to be_a(Hash)
    end
  end

  describe '.write_to_file' do
    it 'writes merged coverage to a file if debug mode is on' do
      path = Dir.pwd + '/coveralls.json'

      expect(STDOUT).to receive(:puts).and_return(
        @puts_one,
        @puts_two,
        "[CoverallsMulti] Debug mode on - writing results to #{path}",
      )

      yml = { 'debug_mode' => true }
      allow(CoverallsMulti::Config).to receive(:yaml_config).and_return(yml)
      allow(File).to receive(:write).and_return(true)

      expect(CoverallsMulti::API.write_to_file(@runner.merge)).to be true
    end

    it 'does not write to file if debug mode is off' do
      expect(STDOUT).to receive(:puts).and_return(
        @puts_one,
        @puts_two,
      )

      yml = {}
      allow(CoverallsMulti::Config).to receive(:yaml_config).and_return(yml)
      allow(File).to receive(:write).and_return(true)

      expect(CoverallsMulti::API.write_to_file(@runner.merge)).to be_falsey
    end
  end
end
