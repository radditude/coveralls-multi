module CoverallsMulti
  # merges coverage files once they're properly formatted
  class Merger
    def merge(formatted_files)
      # we can use the js result as the foundation for now
      # since it already has service_name and service_job_id thanks to coveralls-lcov
      formatter = CoverallsMulti::Formatter.new
      js_result = formatted_files[:javascript]
      ruby_result = CoverallsMulti::Formatter::SimpleCov.new.run(formatted_files[:ruby])
      # add Ruby coverage
      js_result['source_files'].concat ruby_result
      merged = js_result
      # create md5 source digests for all files
      formatter.add_source_digests(merged)
      formatter.add_travis_keys(merged)
      puts 'All files merged and formatted'
      merged
    end
  end
end
