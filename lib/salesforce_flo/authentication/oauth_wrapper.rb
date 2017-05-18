# Copyright (c) 2017, Salesforce.com, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# * Neither the name of Salesforce.com nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'webrick'
require 'launchy'
require 'json'
require 'restforce'

module SalesforceFlo
  module Authentication
    class OauthWrapper

      SFDC_URI = 'https://login.salesforce.com/services/oauth2/authorize'

      def initialize(opts={})
        @client_id = opts[:client_id]
        @redirect_uri = opts[:redirect_uri]
        @client = opts[:client] || -> (options) { Restforce.new(options) }
        raise ArgumentError.new(':client must respond to #call, try a lambda') unless @client.respond_to?(:call)
      end

      def call(opts={})
        server = WEBrick::HTTPServer.new :Port => 8000
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
        query_string = URI.encode_www_form([['client_id', @client_id], ['response_type', 'token'], ['redirect_uri', @redirect_uri]])
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
