RSpec.describe CoverallsMulti::Runner do
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
      expect(STDOUT).to receive(:puts).and_return(
        @puts_one,
        @puts_two,
        '[CoverallsMulti] Validating payload',
      )

      allow(CoverallsMulti::API).to receive(:post_json).and_return('pushed!')

      expect(@runner.start).to eq('pushed!')
    end
  end

  describe '.merge' do
    it 'merges two formatted files' do
      expect(STDOUT).to receive(:puts).and_return(
        @puts_one,
        @puts_two,
      )

      results = @runner.merge
      # TODO: should also compare itself with an existing output file
      expect(results).to be_a(Hash)
    end

    it 'adds source digests' do
      expect(STDOUT).to receive(:puts).and_return(
        @puts_one,
        @puts_two,
      )

      results = @runner.merge

      results['source_files'].each do |src_file|
        expect(src_file['source_digest']).to be_truthy
      end
    end
  end

  describe '.formatter' do
    it 'gets the correct constant from a string' do
      expect(@runner.formatter('simplecov')).to eq(CoverallsMulti::Formatter::Simplecov)
    end

    it 'throws an error if the formatter is not found' do
      expect(STDOUT).to receive(:puts).with('[CoverallsMulti] Could not find formatter CoverallsMulti::Formatter::Fake')
      expect do
        @runner.formatter('fake')
      end.to raise_error NameError
    end
  end
end
