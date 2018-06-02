RSpec.describe CoverallsMulti do
  it 'has a version number' do
    expect(CoverallsMulti::VERSION).not_to be nil
  end

  it 'initializes without throwing' do
    # test initalizer
  end

  it 'loads the files' do
    # test existing file loader w/ hardcoded paths
  end

  # TODO: make file loading more configurable & fault-tolerant
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

  it 'formats Simplecov results files' do
    # this could prob be broken out into multiple tests
  end

  # TODO: convert lcov results using the coveralls-lcov gem in the tool itself
  # it 'converts lcov results files' do
  # end

  # TODO: what do elixir coverage files look like?
  # it 'formats elixir coverage files' do
  # end

  it 'merges two or more formatted files' do
  end

  it 'checks for source digests and adds them if needed' do
  end

  # TODO: add some validators so nobody has to spend their time poring over json files figuring out what went wrong
  # it 'validates the merged file to ensure it is valid JSON' do
  # end

  # it 'validates the merged file to ensure it has all the correct coveralls keys' do
  # end

  # TODO: use coveralls.yml instead of env vars
  it 'adds coveralls keys' do
  end

  it 'calls Coveralls::API.post_json' do
  end

  # TODO: more debugging tools to make it easier to add other formatters in the future
  # it 'takes a flag to run without pushing to Coveralls' do
  # end

  # it 'takes a flag to write output to a file' do
  # end
end
