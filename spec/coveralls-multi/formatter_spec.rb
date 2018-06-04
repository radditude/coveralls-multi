RSpec.describe CoverallsMulti::Formatter do
  let(:yml) do
    {
      'multi' => {
        'simplecov' => 'spec/fixtures/.resultset.json',
        'lcov' => 'spec/fixtures/lcov.info',
      },
    }
  end

  before do
    allow(CoverallsMulti::Config).to receive(:yaml_config).and_return(yml)
    @runner = CoverallsMulti::Runner.new
  end

  describe '.parse_json' do
    it 'parses a JSON file at a given path' do
      expect(CoverallsMulti::Formatter.parse_json('spec/fixtures/coveralls.json')).to be_a(Hash)
    end

    it 'raises an error if the file is not found' do
      path = "#{Dir.pwd}/fakefile.json"
      expect do
        CoverallsMulti::Formatter.parse_json(path)
      end.to raise_error "Could not parse file at #{path}"
    end

    it 'raises an error if the file is not valid JSON' do
      path = "#{Dir.pwd}/spec/fixtures/invalid.json"
      expect do
        CoverallsMulti::Formatter.parse_json(path)
      end.to raise_error "Could not parse file at #{path}"
    end
  end

  describe '::SimpleCov' do
    it 'formats Simplecov results files' do
      results = CoverallsMulti::Formatter::Simplecov.new.run(@runner.files['simplecov'])
      expect(results).to be_a(Array)
    end

    it 'throws an error if there is a problem' do
      path = 'spec/fixtures/.invalidresultset.json'

      expect do
        CoverallsMulti::Formatter::Simplecov.new.run(path)
      end.to raise_error "There was a problem formatting the simplecov report at #{path}"
    end
  end

  describe '::Lcov' do
    it 'converts lcov results files' do
      results = CoverallsMulti::Formatter::Lcov.new.run(@runner.files['lcov'])
      expect(results).to be_a(Array)
    end

    it 'throws an error if conversion was not successful' do
      path = 'fake/path/to/nothing'

      expect do
        CoverallsMulti::Formatter::Lcov.new.run(path)
      end.to raise_error "There was a problem converting the lcov file at #{path}"
    end
  end

  # TODO: what do elixir coverage files look like?
  it 'formats elixir coverage files'
end
