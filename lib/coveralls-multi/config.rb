module CoverallsMulti
  class Config
    def self.root(root = nil)
      return @root if defined?(@root) && root.nil?
      @root = File.expand_path(root || Dir.getwd)
    end
  end
end
