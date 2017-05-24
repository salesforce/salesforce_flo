# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../../test_helper'
require 'flo/provider/salesforce_flo'
require 'ostruct'

module Flo
  module Provider
    class SalesforceFloTest < ::SalesforceFlo::UnitTest

      def subject
        @subject ||= begin
          opts = { client: client }
          ::Flo::Provider::SalesforceFlo.new(opts)
        end
      end

      def client
        @client ||= Minitest::Mock.new
      end

      def test_update_object_is_successful
        client.expect(:find, OpenStruct.new(Id: '12345'), ['agf__ADM_Work__c', 'w-0001', 'Name'])
        client.expect(:update, OpenStruct.new(success?: false), ['agf__ADM_Work__c', {Id: '12345', agf__Status__c: 'In Progress'}])
        assert subject.update_object(sobject: 'agf__ADM_Work__c', name: 'w-0001', fields: { agf__Status__c: 'In Progress' }).success?

        client.verify
      end

      def test_object_returns_object
        mock_object = Object.new
        client.expect(:find, mock_object, ['some_Object_API_Name', '1234', 'Name'])

        assert_same mock_object, subject.object('some_Object_API_Name', '1234')

        client.verify
      end

    end
  end
end
