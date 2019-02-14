[![coveralls-multi](https://img.shields.io/gem/v/coveralls-multi.svg)](https://rubygems.org/gems/coveralls-multi) [![Travis](https://img.shields.io/travis/radditude/coveralls-multi/master.svg)](https://travis-ci.org/radditude/coveralls-multi) [![Coverage Status](https://coveralls.io/repos/github/radditude/coveralls-multi/badge.svg)](https://coveralls.io/github/radditude/coveralls-multi)

# CoverallsMulti

CoverallsMulti is a Coveralls client with support for multi-language repos. Once you've set up coverage tools for all the languages in your repo, specify the paths to your coverage output files in `.coveralls.yml` and let CoverallsMulti handle formatting them, merging them into one big superfile, and posting the result to Coveralls.io.

### Currently supported:

#### Languages & Output Formats

| _Language_ | _Coverage tool_                                                                    | _Config key_  |
| ---------- | ---------------------------------------------------------------------------------- | ------------- |
| Elixir     | [ExCoveralls](https://github.com/parroty/excoveralls) (JSON output)                | `excoveralls` |
| JavaScript | [nyc](https://github.com/istanbuljs/nyc), or any tool that can output an lcov file | `lcov`        |
| Ruby       | [SimpleCov](https://github.com/colszowka/simplecov)                                | `simplecov`   |

#### CI Providers

- TravisCI

#### Coming Soon

Have another language, tool, or CI provider you'd like to see supported? [File an issue](https://github.com/radditude/coveralls-multi/issues/new).

## Installation

Add this line to the test group in your application's Gemfile:

```ruby
gem 'coveralls-multi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coveralls-multi

## Usage

0. Set up coverage measurement for each language. Coveralls-multi is only concerned with formatting & posting the output files, so choice of tooling is up to you.

1. Once you know where the output files will go, set up your `.coveralls.yml` with the appropriate keys and paths like so (see supported languages above for more details on the supported config keys):

```
service_name: travis-ci
repo_token: [REPO_TOKEN]
multi:
  simplecov: coverage/.resultset.json
  lcov: coverage/lcov.info
  excoveralls: cover/excoveralls.json
```

2. Run `coveralls-multi` to merge the output files and send them to Coveralls. In a CI environment, you can run `coveralls-multi` as an final step after you run your test commands.

_Note for ExCoveralls:_ Currently, formatting will break if the ExCoveralls output directory is called something other than the default `cover`. You don't need to worry about this unless you've changed the default `output_dir` in your ExCoveralls config.

## Troubleshooting

Debug mode will save and output the merged file so you can take a closer look. To enable debug mode, add the following line to `.coveralls.yml`:

```
debug_mode: true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

TODO: add better contributing instructions (especially for adding a new formatter)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/radditude/coveralls-multi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CoverallsMulti project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/radditude/coveralls-multi/blob/master/CODE_OF_CONDUCT.md).
