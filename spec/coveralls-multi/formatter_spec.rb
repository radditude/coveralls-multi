RSpec.describe CoverallsMulti::Formatter do
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
  end

  describe '.parse_json' do
    it 'parses a JSON file at a given path' do
      expect(CoverallsMulti::Formatter.parse_json('spec/fixtures/coveralls.json')).to be_a(Hash)
    end

    it 'raises an error if the file is not found' do
      path = "#{Dir.pwd}/fakefile.json"

      expect(STDOUT).to receive(:puts).and_return("[CoverallsMulti] Could not parse file at #{path}")

      expect do
        CoverallsMulti::Formatter.parse_json(path)
      end.to raise_error Errno::ENOENT
    end

    it 'raises an error if the file is not valid JSON' do
      path = "#{Dir.pwd}/spec/fixtures/invalid.json"

      expect(STDOUT).to receive(:puts).and_return("[CoverallsMulti] Could not parse file at #{path}")

      expect do
        CoverallsMulti::Formatter.parse_json(path)
      end.to raise_error Errno::ENOENT
    end
  end

  describe '::SimpleCov' do
    it 'formats Simplecov results files' do
      results = CoverallsMulti::Formatter::Simplecov.new.run(@runner.files['simplecov'])
      expect(results).to be_a(Array)
    end

    it 'formats Simplecov results files with multiple suites' do
      results = CoverallsMulti::Formatter::Simplecov.new.run('spec/fixtures/simplecov-multisuite.json')

      results_files = results.map { |result| result['name'] }.sort
      expect(results).to be_a(Array)
      expect(results_files).to eq([
        'spec/fixtures/dummy_ruby1.rb',
        'spec/fixtures/dummy_ruby1.rb',
        'spec/fixtures/dummy_ruby2.rb',
      ])
    end

    it 'throws an error if there is a problem' do
      path = 'spec/fixtures/.invalidresultset.json'

      expect(STDOUT).to receive(:puts).and_return(
        "[CoverallsMulti] There was a problem formatting the simplecov report file at #{path}",
        '[CoverallsMulti] Make sure the file exists.',
      )

      expect do
        CoverallsMulti::Formatter::Simplecov.new.run(path)
      end.to raise_error Errno::ENOENT
    end
  end

  describe '::Lcov' do
    it 'converts lcov results files' do
      results = CoverallsMulti::Formatter::Lcov.new.run(@runner.files['lcov'])
      expect(results).to be_a(Array)
    end

    it 'throws an error if conversion was not successful' do
      path = 'fake/path/to/nothing'

      expect(STDOUT).to receive(:puts).and_return(
        "Could not read tracefile: #{path}",
        "Errno::ENOENT: No such file or directory @ rb_sysopen - #{path}",
      )

      expect do
        CoverallsMulti::Formatter::Lcov.new.run(path)
      end.to raise_error SystemExit
    end
  end

  describe '::Excoveralls' do
    it 'converts excoveralls json results files' do
      results = CoverallsMulti::Formatter::Excoveralls.new.run(@runner.files['excoveralls'])
      expect(results).to be_a(Array)
    end

    it 'throws an error if conversion was not successful' do
      path = 'fake/path/to/nothing'
      expect(STDOUT).to receive(:puts).and_return(
        "[CoverallsMulti] Could not parse file at #{path}",
        "[CoverallsMulti] There was a problem converting the excoveralls file at #{path}",
        '[CoverallsMulti] Make sure the file exists.',
      )
      expect do
        CoverallsMulti::Formatter::Excoveralls.new.run(path)
      end.to raise_error Errno::ENOENT
    end
  end
end
