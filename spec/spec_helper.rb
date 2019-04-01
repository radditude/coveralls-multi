require 'coveralls'
require 'simplecov'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter,
]

SimpleCov.start do
  add_filter "/spec/"
end

require 'bundler/setup'
require 'coveralls-multi'
require 'json'
require 'webmock/rspec'

simplecov = {
  'RSpec' => {
    'coverage' => {
      "#{Dir.pwd}/spec/coveralls_multi_spec.rb" => [
        1,
        1,
        1,
      ],
    },
    'timestamp' => 1_527_992_228,
  },
}

lcov = <<-LCOV
  TN:
  SF:#{Dir.pwd}/spec/fixtures/fake.js
  FNF:0
  FNH:0
  DA:1,1
  DA:2,1
  DA:3,1
  LF:3
  LH:3
  BRF:0
  BRH:0
  end_of_record
LCOV

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # generate fixtures
  config.before(:all) {File.write('spec/fixtures/lcov.info', lcov)}
  config.before(:all) {File.write('spec/fixtures/.resultset.json', JSON.generate(simplecov))}
end
