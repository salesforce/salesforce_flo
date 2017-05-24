# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'webrick'
require 'launchy'
require 'json'
require 'restforce'

module SalesforceFlo
  module Authentication
    class OauthWrapper

      SFDC_URI = 'https://login.salesforce.com/services/oauth2/authorize'
      DEFAULT_CLIENT_ID = '3MVG9CEn_O3jvv0zPd34OzgiH037XR5Deez3GW8PpsMdzoxecdKUW1s.8oYU9GoLS2Tykr4qTrCizaQBjRXNT'
      DEFAULT_REDIRECT_HOSTNAME = 'localhost'
      DEFAULT_LISTEN_PORT = '3835'

      # Creates a new OauthWrapper instance
      #
      # @param [Hash] opts The options needed to create the provider
      # @option opts [String] :client_id The client id of the connected app for Oauth authorization
      # @option opts [String] :redirect_hostname (http://localhost:3835) The hostname portion of the uri
      # that the user will be redirected to at the end of the Oauth authorization flow.  This MUST match the
      # redirect URL specified in the connected app settings.
      # @option opts [String] :port (3835) The port that the user will be redirected to at the end of the Oauth
      # flow.  This will be appended to the redirect_hostname
      # @option opts [#call] :client An object that produces a client when called with initialization options
      # @raise [ArgumentError] If client object does not respond_to?(:call)
      #
      def initialize(opts={})
        @client_id = opts[:client_id] || DEFAULT_CLIENT_ID
        @redirect_hostname = opts[:redirect_hostname] || DEFAULT_REDIRECT_HOSTNAME
        @port = opts[:port] || DEFAULT_LISTEN_PORT
        @client = opts[:client] || -> (options) { Restforce.new(options) }
        raise ArgumentError.new(':client must respond to #call, try a lambda') unless @client.respond_to?(:call)
      end

      # Starts a temporary webserver on the specified port, and initiates an Oauth authorization flow, which will
      # redirect the user back to localhost on the specified port.
      #
      # @param [Hash] opts Options that will be passed to the client when called, which will be merged with the response
      # from the salesforce that includes the access token
      # @return The result of invoking #call on the client object
      def call(opts={})
        server = WEBrick::HTTPServer.new :Port => @redirect_hostname
        auth_details = {}

        server.mount_proc('/') do |req, res|
          res.body = js_template
        end

        server.mount_proc('/send_token') do |req, res|
          auth_details = JSON.parse(req.body)
          res.body = 'token sent'

          server.shutdown # server will shutdown after completing the request
        end

        trap "INT" do server.shutdown end

        Launchy.open("#{SFDC_URI}?#{oauth_query_string}")
        server.start

        merged_options = opts.merge(auth_details).merge(client_id: @client_id, api_version: '38.0').inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

        @client.call(merged_options)
      end

      private

      def oauth_query_string
        query_string = URI.encode_www_form([['client_id', @client_id], ['response_type', 'token'], ['redirect_uri', redirect_uri]])
      end

      def redirect_uri
        "http://#{@redirect_hostname}:#{@port}"
      end

      def js_template
        <<-TEMPLATE
          <html>
          <head></head>
          <body onload="sendHashParams()">
            OAuth authentication completed successfully.  This window will close shortly.
            <script>
              function getHashParams() {

                  var hashParams = {};
                  var e,
                      a = /\\+/g,  // Regex for replacing addition symbol with a space
                      r = /([^&;=]+)=?([^&;]*)/g,
                      d = function (s) { return decodeURIComponent(s.replace(a, " ")); },
                      q = window.location.hash.substring(1);

                  while (e = r.exec(q))
                     hashParams[d(e[1])] = d(e[2]);

                  return hashParams;
              }

              function sendHashParams() {
                xhr = new XMLHttpRequest();
                var url = "http://localhost:8000/send_token";
                xhr.open("POST", url, true);
                xhr.setRequestHeader("Content-type", "application/json");
                var data = JSON.stringify(getHashParams());
                xhr.send(data);

                setTimeout(function() {
                  window.close;
                }, (10 * 1000))
              }
            </script>
          </body>
        </html>
        TEMPLATE
      end

    end
  end
end
