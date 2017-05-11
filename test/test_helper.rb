$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'salesforce_flo'

ENV["MT_NO_SKIP_MSG"] = "true"

require 'minitest/autorun'
require 'pry'

module SalesforceFlo
  class UnitTest < Minitest::Test
    self.parallelize_me!
  end
end