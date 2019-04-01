RSpec.describe CoverallsMulti::Validator do
  describe '.run' do
    it 'checks that the payload is valid JSON' do
      expect(STDOUT).to receive(:puts).and_return(
        '[CoverallsMulti] Payload could not be parsed to JSON!',
      )

      invalid_payload = {}
      invalid_payload['💩'] = "\xC3"
      validator = CoverallsMulti::Validator.new invalid_payload

      expect { validator.run }.to raise_error(JSON::UnparserError)
    end

    it 'checks that the payload is not empty' do
      expect do
        CoverallsMulti::Validator.new('').run
      end.to raise_error('Payload is empty!')
      expect do
        CoverallsMulti::Validator.new(nil).run
      end.to raise_error('Payload is empty!')
      expect do
        CoverallsMulti::Validator.new(['not a hash']).run
      end.to raise_error('Payload should be a hash!')
      expect do
        CoverallsMulti::Validator.new('this is just a string').run
      end.to raise_error('Payload should be a hash!')
    end

    it 'checks that the payload has required top-level keys' do
      invalid_payload = {}
      invalid_payload['not_a_coveralls_key'] = 'random value'
      validator = CoverallsMulti::Validator.new(invalid_payload)

      expect { validator.run }.to raise_error(
        'Missing required top-level key - source_files',
      )
    end

    it 'checks that the payload has required source file keys' do
      payload = JSON.parse(IO.read('spec/fixtures/coveralls-invalid.json'))
      validator = CoverallsMulti::Validator.new payload

      expect { validator.run }.to raise_error(
        'Missing required source file key(s) - name, source_digest, coverage, source',
      )
    end

    it 'does not throw if payload is valid' do
      payload = JSON.parse(IO.read('spec/fixtures/coveralls.json'))
      validator = CoverallsMulti::Validator.new payload

      expect { validator.run }.not_to raise_error
    end
  end
end
