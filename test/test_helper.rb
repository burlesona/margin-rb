$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "margin"

require "minitest/autorun"
require "minitest/spec"
require "minitest/reporters"
Minitest::Reporters.use!
