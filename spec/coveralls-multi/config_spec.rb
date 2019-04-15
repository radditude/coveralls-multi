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
          'simplecov' => 'spec/fixtures/.resultset.json',
          'lcov' => 'spec/fixtures/lcov.info',
        },
      }
      expect(CoverallsMulti::Config.yaml_config).to eq(yml)
    end

    it 'raises an error if it cannot read the config file' do
      allow(CoverallsMulti::Config).to receive(:root).and_return("#{Dir.pwd}/fake")

      expect { CoverallsMulti::Config.yaml_config }.to raise_error "[CoverallsMulti] Couldn't find config file"
    end
  end

  describe '.files' do
    it 'can return the coveralls-multi config' do
      yml = {
        'simplecov' => 'spec/fixtures/.resultset.json',
        'lcov' => 'spec/fixtures/lcov.info',
      }
      allow(CoverallsMulti::Config).to receive(:root).and_return("#{Dir.pwd}/spec/fixtures")
      expect(CoverallsMulti::Config.files).to eq(yml)
    end

    it 'raises an error if no coveralls-multi config is found' do
      yml = { 'repo_token' => 'xyz' }
      allow(CoverallsMulti::Config).to receive(:yaml_config).and_return(yml)
      expect do
        CoverallsMulti::Config.files
      end.to raise_error "[CoverallsMulti] Couldn't find multi configuration in .coveralls.yml"
    end
  end

  describe '.debug_mode' do
    it 'returns false if debug_mode is not specified in yaml config' do
      yml = { 'a_key' => 'a_value' }

      allow(CoverallsMulti::Config).to receive(:yaml_config).and_return(yml)
      expect(CoverallsMulti::Config.debug_mode).to be_falsey
    end

    it 'returns true if debug_mode is true' do
      yml = { 'debug_mode' => true }

      allow(CoverallsMulti::Config).to receive(:yaml_config).and_return(yml)
      expect(CoverallsMulti::Config.debug_mode).to be_truthy
    end
  end

  describe '.add_ci_env' do
    describe 'Travis' do
      it 'adds the correct info when service_name is specified' do
        stub_const(
          'ENV',
          'TRAVIS' => true,
          'TRAVIS_JOB_ID' => 1,
          'TRAVIS_BRANCH' => 'test',
        )
        allow(CoverallsMulti::Config).to receive(:yaml_config).and_return('service_name' => 'travis-pro')

        result = CoverallsMulti::Config.add_ci_env({git:{}})

        expect(result[:service_name]).to eq('travis-pro')
        expect(result[:service_job_id]).to eq(1)
        expect(result[:service_branch]).to eq('test')
        expect(result[:git][:branch]).to eq('test')
      end

      it 'adds the correct info when service_name is not specified' do
        stub_const(
          'ENV',
          'TRAVIS' => true,
          'TRAVIS_JOB_ID' => 1,
          'TRAVIS_BRANCH' => 'test',
        )
        allow(CoverallsMulti::Config).to receive(:yaml_config).and_return({})

        result = CoverallsMulti::Config.add_ci_env({git:{}})

        expect(result[:service_name]).to eq('travis-ci')
        expect(result[:service_job_id]).to eq(1)
        expect(result[:service_branch]).to eq('test')
        expect(result[:git][:branch]).to eq('test')
      end
    end

    describe 'CircleCI' do
      it 'adds the correct info' do
        stub_const(
          'ENV',
          'CIRCLECI' => true,
          'CIRCLE_BUILD_NUM' => 1,
          'CIRCLE_NODE_INDEX' => 2,
          'CIRCLE_BRANCH' => 'test',
        )

        result = CoverallsMulti::Config.add_ci_env({git:{}})

        expect(result[:service_name]).to eq('circleci')
        expect(result[:service_number]).to eq(1)
        expect(result[:service_job_number]).to eq(2)
        expect(result[:git][:branch]).to eq('test')
      end
    end

    describe 'Semaphore' do
      it 'adds the correct info' do
        stub_const(
          'ENV',
          'SEMAPHORE' => true,
          'SEMAPHORE_BUILD_NUMBER' => 1,
          'PULL_REQUEST_NUMBER' => 2,
          'BRANCH_NAME' => 'test',
        )

        result = CoverallsMulti::Config.add_ci_env({git:{}})

        expect(result[:service_name]).to eq('semaphore')
        expect(result[:service_number]).to eq(1)
        expect(result[:service_pull_request]).to eq(2)
        expect(result[:git][:branch]).to eq('test')
      end
    end

    describe 'Jenkins' do
      it 'adds the correct info' do
        stub_const(
          'ENV',
          'JENKINS_HOME' => true,
          'BUILD_NUMBER' => 1,
          'BRANCH_NAME' => 'test',
        )

        result = CoverallsMulti::Config.add_ci_env({git:{}})

        expect(result[:service_name]).to eq('jenkins')
        expect(result[:service_number]).to eq(1)
        expect(result[:service_branch]).to eq('test')
        expect(result[:git][:branch]).to eq('test')
      end
    end

    describe 'Appvoyer' do
      it 'adds the correct info' do
        stub_const(
          'ENV',
          'APPVEYOR' => true,
          'APPVEYOR_BUILD_VERSION' => 1,
          'APPVEYOR_REPO_NAME' => 'test',
          'APPVEYOR_REPO_BRANCH' => 'test'
        )

        result = CoverallsMulti::Config.add_ci_env({git:{}})

        expect(result[:service_name]).to eq('appveyor')
        expect(result[:service_number]).to eq(1)
        expect(result[:git][:branch]).to eq('test')
        expect(result[:service_build_url]).to eq('https://ci.appveyor.com/project/test/build/1')
      end
    end

    describe 'Gitlab' do
      it 'adds the correct info' do
        stub_const(
          'ENV',
          'GITLAB_CI' => true,
          'CI_BUILD_NAME' => 1,
          'CI_BUILD_REF' => 2,
          'CI_BUILD_REF_NAME' => 'test',
        )

        result = CoverallsMulti::Config.add_ci_env({git:{}})

        expect(result[:service_name]).to eq('gitlab-ci')
        expect(result[:service_job_number]).to eq(1)
        expect(result[:commit_sha]).to eq(2)
        expect(result[:git][:branch]).to eq('test')
      end
    end

    describe 'Local' do
      it 'adds the correct info' do
        stub_const(
          'ENV',
          'COVERALLS_RUN_LOCALLY' => true,
        )

        result = CoverallsMulti::Config.add_ci_env({git:{}})

        expect(result[:service_name]).to eq('coveralls-multi')
        expect(result[:service_job_id]).to eq(nil)
        expect(result[:service_branch]).to eq(nil)
      end
    end
  end
end
