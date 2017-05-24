# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'pry'

module Flo
  module Provider
    class SalesforceFlo


      # Creates a new SalesforceFlo Provider instance
      #
      # @param [Hash] opts The options needed to create the provider
      # @option opts [Restforce, #call] :client An instance of a Restforce client, or
      #   an object that will produce a client when #call is invoked
      #
      def initialize(opts={})
        @client = if opts[:client].respond_to? :call
          opts[:client].call
        else
          opts[:client]
        end
      end

      # Updates a Salesforce object using the client
      #
      # @param [Hash] opts The options needed to update the object
      # @option opts [String] :sobject The api name of the sobject to update
      # @option opts [String] :name The name of the object instance you wish to update
      # @option opts [Hash] :fields A mapping of the field names and values you wish to update
      #
      def update_object(opts={})
        sobject = opts.delete(:sobject)

        object = @client.find(sobject, opts.delete(:name), 'Name')
        @client.update(sobject, opts[:fields].merge(Id: object.Id))
        OpenStruct.new(success?: true)
      end

      # Provides the current state of a Salesforce object
      #
      # @param sobject [String] The api name of sobject to query
      # @param object_name [String] The name of the object instance to search for
      def object(sobject, object_name)
        @client.find(sobject, object_name, 'Name')
      end

    end
  end
end
