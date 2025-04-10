require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  track_files "lib/**/*.rb"
  enable_coverage :branch
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "lzstring"

require "minitest/autorun"
