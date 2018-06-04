
RSpec.describe CoverallsMulti do
  let(:yml) {
    {
      'multi' => {
        'ruby' => 'spec/fixtures/.resultset.json',
        'javascript' => 'spec/fixtures/jscov.json',
      }
    }
  }

  before do
    allow(CoverallsMulti::Config).to receive(:yaml_config).and_return(yml)
    @runner = CoverallsMulti::Runner.new
  end

  it 'has a version number' do
    expect(CoverallsMulti::VERSION).not_to be nil
  end

  describe CoverallsMulti::Runner do
    it 'initializes without throwing' do
      expect { CoverallsMulti::Runner.new }.not_to raise_error
    end

    it 'loads the files' do
      expect(@runner.files).to be_a(Hash)
    end

    it 'calls Coveralls::API.post_json' do
      allow(Coveralls::API).to receive(:post_json).and_return('pushed!')

      expect(@runner.start).to eq('pushed!')
    end

    it 'merges two formatted files' do
      results = @runner.merge
      # TODO: should also compare itself with an existing output file
      expect(results).to be_a(Hash)
    end

    it 'adds travis keys' do
      results = @runner.merge

      expect(results['service_name']).to eq('travis-pro')
      expect(results['repo_token']).to be_a(String)
    end
  end

  describe CoverallsMulti::Config do
    it 'can return the repo root path' do
      expect(CoverallsMulti::Config.root).to eq(File.expand_path(Dir.getwd))
    end
  end

  # it 'throws an error if a file is not found' do
  # end

  # it 'uses a default coverage directory if none is specified' do
  # end

  # it 'iterates over a coverage directory and checks for known filetypes' do
  # end

  # it 'checks for a coveralls.yml file' do
  # end

  # it 'reads file paths from yaml config' do
  # end

  # it 'has a wizard to help with setup' do
  # end

  # TODO: allow coveralls-multi to run your tests for you too
  # it 'can take a set of test commands to run' do
  # end

  describe CoverallsMulti::Formatter do
    it 'formats Simplecov results files' do
      results = CoverallsMulti::Formatter::SimpleCov.new.run(@runner.files['ruby'])
      # TODO: have this compare against an existing output file
      expect(results).to be_a(Array)
    end
  end

  # TODO: convert lcov results using the coveralls-lcov gem in the tool itself
  # it 'converts lcov results files' do
  # end

  # TODO: what do elixir coverage files look like?
  # it 'formats elixir coverage files' do
  # end

  # it 'checks for source digests and adds them if needed' do
  #   pending
  # end

  # TODO: use coveralls.yml instead of env vars

  # TODO: more debugging tools to make it easier to add other formatters in the future
  # it 'takes a flag to run without pushing to Coveralls' do
  # end

  # it 'takes a flag to write output to a file' do
  # end
end
