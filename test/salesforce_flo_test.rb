require 'test_helper'

class SalesforceFloTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SalesforceFlo::VERSION
  end
end
