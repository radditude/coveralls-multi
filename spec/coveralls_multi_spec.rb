
RSpec.describe CoverallsMulti do
  it 'has a version number' do
    expect(CoverallsMulti::VERSION).not_to be nil
  end

  # TODO: take a path to a coverage directory and iterate over it to find files to push
  # it 'uses a default coverage directory if none is specified' do
  # end

  # it 'iterates over a coverage directory and checks for known filetypes' do
  # end

  # TODO: allow coveralls-multi to run your tests for you too
  # it 'can take a set of test commands to run' do
  # end

  # TODO: more debugging tools to make it easier to add other formatters in the future
  # it 'takes a flag to run without pushing to Coveralls' do
  # end
end
