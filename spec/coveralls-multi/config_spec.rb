RSpec.describe CoverallsMulti::Config do
  describe '.root' do
    it 'can return the repo root path' do
      expect(CoverallsMulti::Config.root).to eq(Dir.pwd)
    end
  end

  describe '.configuration_path' do
    it 'can return the path to the configuration file' do
      expect(CoverallsMulti::Config.configuration_path).to eq("#{Dir.pwd}/.coveralls.yml")
    end
  end

  describe '.yaml_config' do
    it 'can read the config file' do
      allow(CoverallsMulti::Config).to receive(:root).and_return("#{Dir.pwd}/spec/fixtures")
      yml = {
        'repo_token' => 'zyx',
        'service_name' => 'travis-ci',
        'multi' => {
          'ruby' => 'spec/fixtures/.resultset.json',
          'javascript' => 'spec/fixtures/jscov.json',
        },
      }
      expect(CoverallsMulti::Config.yaml_config).to eq(yml)
    end

    it 'raises an error if it cannot read the config file' do
      allow(CoverallsMulti::Config).to receive(:root).and_return("#{Dir.pwd}/fake")

      expect { CoverallsMulti::Config.yaml_config }.to raise_error "Couldn't find config file"
    end
  end

  describe '.files' do
    it 'can return the coveralls-multi config' do
      yml = {
        'ruby' => 'spec/fixtures/.resultset.json',
        'javascript' => 'spec/fixtures/jscov.json',
      }
      allow(CoverallsMulti::Config).to receive(:root).and_return("#{Dir.pwd}/spec/fixtures")
      expect(CoverallsMulti::Config.files).to eq(yml)
    end

    it 'raises an error if no coveralls-multi config is found' do
      yml = {'repo_token' => 'xyz'}
      allow(CoverallsMulti::Config).to receive(:yaml_config).and_return(yml)
      expect do
        CoverallsMulti::Config.files
      end.to raise_error "Couldn't find coveralls-multi configuration in .coveralls.yml"
    end
  end

  # it 'takes a flag to write output to a file' do
  # end
end
