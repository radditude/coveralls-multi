module CoverallsMulti
  # merges coverage files once they're properly formatted
  class Merger
    def self.merge(formatted_files)
      # we can use the js result as the foundation for now
      # since it already has service_name and service_job_id thanks to coveralls-lcov
      js_result = formatted_files[:javascript]
      ruby_result = CoverallsMulti::Formatter::SimpleCov.run(formatted_files[:ruby])
      # add Ruby coverage
      js_result['source_files'].concat ruby_result
      merged = js_result
      # create md5 source digests for all files
      merged['source_files'] = CoverallsMulti::Formatter.add_source_digests(merged['source_files'])
      merged
    end
  end
end
