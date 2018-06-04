RSpec.describe CoverallsMulti::Runner do
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

  describe '.initialize' do
    it 'initializes without throwing' do
      expect { CoverallsMulti::Runner.new }.not_to raise_error
    end
  end

  describe '.files' do
    it 'loads the files' do
      expect(@runner.files).to be_a(Hash)
    end
  end

  describe '.start' do
    it 'calls Coveralls::API.post_json' do
      allow(Coveralls::API).to receive(:post_json).and_return('pushed!')

      expect(@runner.start).to eq('pushed!')
    end
  end

  describe '.merge' do
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

    it 'adds source digests' do
      results = @runner.merge

      results['source_files'].each do |src_file|
        expect(src_file['source_digest']).to be_truthy
      end
    end
  end
end
