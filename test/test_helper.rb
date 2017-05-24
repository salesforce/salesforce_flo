# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

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
