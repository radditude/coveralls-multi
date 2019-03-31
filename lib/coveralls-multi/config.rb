require 'yaml'

module CoverallsMulti
  # reads .coveralls.yml and sets module config options
  class Config
    class << self
      def yaml_config
        raise "Couldn't find config file" unless configuration_path && File.exist?(configuration_path)

        YAML.load_file(configuration_path)
      end

      def files
        yml = yaml_config['multi']

        raise "Couldn't find coveralls-multi configuration in .coveralls.yml" unless yml

        yml
      end

      def debug_mode
        yaml_config['debug_mode'] || ENV['COVERALLS_DEBUG']
      end

      def root
        Dir.pwd
      end

      def configuration_path
        File.expand_path(File.join(root, '.coveralls.yml')) if root
      end

      def api_domain
        ENV['COVERALLS_ENDPOINT'] || 'https://coveralls.io'
      end

      def api_endpoint
        "#{api_domain}/api/v1/jobs"
      end

      def api_config
        config = {
          git: git_info,
          repo_token: ENV['COVERALLS_REPO_TOKEN'] || yml['repo_token'] || yml['repo_secret_token'],
        }

        add_ci_env(config)
        add_standard_service_params_for_generic_ci(config)
        config
      end

      def git_info
        Dir.chdir(root) do
          {
            head: git_head,
            branch: git_branch,
            remotes: git_remotes,
          }
        end
      rescue StandardError => e
        puts 'Problem gathering git info:'
        puts e.to_s
        nil
      end

      def git_head
        {
          id: ENV.fetch('GIT_ID', `git log -1 --pretty=format:'%H'`),
          author_name: ENV.fetch('GIT_AUTHOR_NAME', `git log -1 --pretty=format:'%aN'`),
          author_email: ENV.fetch('GIT_AUTHOR_EMAIL', `git log -1 --pretty=format:'%ae'`),
          committer_name: ENV.fetch('GIT_COMMITTER_NAME', `git log -1 --pretty=format:'%cN'`),
          committer_email: ENV.fetch('GIT_COMMITTER_EMAIL', `git log -1 --pretty=format:'%ce'`),
          message: ENV.fetch('GIT_MESSAGE', `git log -1 --pretty=format:'%s'`),
        }
      end

      def git_branch
        ENV.fetch('GIT_BRANCH', `git rev-parse --abbrev-ref HEAD`)
      end

      def git_remotes
        `git remote -v`.split(/\n/).map do |remote|
          split_line = remote.split(' ').compact
          { name: split_line[0], url: split_line[1] }
        end.uniq
      end

      def add_ci_env(config)
        return add_service_params_for_travis(config, yml ? yml['service_name'] : nil) if ENV['TRAVIS']
        return add_service_params_for_circleci(config) if ENV['CIRCLECI']
        return add_service_params_for_semaphore(config) if ENV['SEMAPHORE']
        return add_service_params_for_jenkins(config) if ENV['JENKINS_URL'] || ENV['JENKINS_HOME']
        return add_service_params_for_appveyor(config) if ENV['APPVEYOR']
        return add_service_params_for_tddium(config) if ENV['TDDIUM']
        return add_service_params_for_gitlab(config) if ENV['GITLAB_CI']
        return add_service_params_for_coveralls_local(config) if ENV['COVERALLS_RUN_LOCALLY']

        nil
      end

      def add_service_params_for_travis(config, service_name)
        config[:service_job_id] = ENV['TRAVIS_JOB_ID']
        config[:service_pull_request] = ENV['TRAVIS_PULL_REQUEST'] unless ENV['TRAVIS_PULL_REQUEST'] == 'false'
        config[:service_name]   = service_name || 'travis-ci'
        config[:service_branch] = ENV['TRAVIS_BRANCH']
      end

      def add_service_params_for_circleci(config)
        config[:service_name]         = 'circleci'
        config[:service_number]       = ENV['CIRCLE_BUILD_NUM']
        config[:service_pull_request] = (ENV['CI_PULL_REQUEST'] || '')[/(\d+)$/, 1]
        config[:parallel]             = ENV['CIRCLE_NODE_TOTAL'].to_i > 1
        config[:service_job_number]   = ENV['CIRCLE_NODE_INDEX']
      end

      def add_service_params_for_semaphore(config)
        config[:service_name]         = 'semaphore'
        config[:service_number]       = ENV['SEMAPHORE_BUILD_NUMBER']
        config[:service_pull_request] = ENV['PULL_REQUEST_NUMBER']
      end

      def add_service_params_for_jenkins(config)
        config[:service_name]   = 'jenkins'
        config[:service_number] = ENV['BUILD_NUMBER']
        config[:service_branch] = ENV['BRANCH_NAME']
        config[:service_pull_request] = ENV['ghprbPullId']
      end

      def add_service_params_for_appveyor(config)
        config[:service_name]   = 'appveyor'
        config[:service_number] = ENV['APPVEYOR_BUILD_VERSION']
        config[:service_branch] = ENV['APPVEYOR_REPO_BRANCH']
        config[:commit_sha] = ENV['APPVEYOR_REPO_COMMIT']
        repo_name = ENV['APPVEYOR_REPO_NAME']
        config[:service_build_url] = format('https://ci.appveyor.com/project/%s/build/%s', repo_name, config[:service_number])
      end

      def add_service_params_for_tddium(config)
        config[:service_name]         = 'tddium'
        config[:service_number]       = ENV['TDDIUM_SESSION_ID']
        config[:service_job_number]   = ENV['TDDIUM_TID']
        config[:service_pull_request] = ENV['TDDIUM_PR_ID']
        config[:service_branch]       = ENV['TDDIUM_CURRENT_BRANCH']
        config[:service_build_url]    = "https://ci.solanolabs.com/reports/#{ENV['TDDIUM_SESSION_ID']}"
      end

      def add_service_params_for_gitlab(config)
        config[:service_name]         = 'gitlab-ci'
        config[:service_job_number]   = ENV['CI_BUILD_NAME']
        config[:service_job_id]       = ENV['CI_BUILD_ID']
        config[:service_branch]       = ENV['CI_BUILD_REF_NAME']
        config[:commit_sha]           = ENV['CI_BUILD_REF']
      end

      def add_service_params_for_coveralls_local(config)
        config[:service_job_id]     = nil
        config[:service_name]       = 'coveralls-ruby'
        config[:service_event_type] = 'manual'
      end

      def add_standard_service_params_for_generic_ci(config)
        config[:service_name]         ||= ENV['CI_NAME']
        config[:service_number]       ||= ENV['CI_BUILD_NUMBER']
        config[:service_job_id]       ||= ENV['CI_JOB_ID']
        config[:service_build_url]    ||= ENV['CI_BUILD_URL']
        config[:service_branch]       ||= ENV['CI_BRANCH']
        config[:service_pull_request] ||= (ENV['CI_PULL_REQUEST'] || '')[/(\d+)$/, 1]
      end
    end
  end
end
