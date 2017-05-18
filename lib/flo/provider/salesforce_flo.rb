require 'pry'

module Flo
  module Provider
    class SalesforceFlo

      def initialize(opts={})
        @client = if opts[:client].respond_to? :call
          opts[:client].call
        else
          opts[:client]
        end
      end

      def update_object(opts={})
        sobject = opts.delete(:sobject)

        object = @client.find(sobject, opts.delete(:name), 'Name')
        @client.update(sobject, opts[:fields].merge(Id: object.Id))
        OpenStruct.new(success?: true)
      end

      def object(object, object_name)
        @client.find(object, object_name, 'Name')
      end

    end
  end
end
