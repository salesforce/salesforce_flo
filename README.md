# SalesforceFlo
[![Gem Version](https://badge.fury.io/rb/salesforce_flo.svg)](https://badge.fury.io/rb/salesforce_flo) [![Code Climate](https://codeclimate.com/github/salesforce/salesforce_flo/badges/gpa.svg)](https://codeclimate.com/github/salesforce/salesforce_flo) [![Build Status](https://semaphoreci.com/api/v1/justinpowers/salesforce_flo/branches/master/shields_badge.svg)](https://semaphoreci.com/justinpowers/salesforce_flo)

SalesforceFlo is a Salesforce plugin for the Flo workflow automation library.  If you aren't familiar with Flo, then please start [here](https://github.com/salesforce/flo)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'salesforce_flo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install salesforce_flo

## Configuration

In your Flo configuration file, configure salesforce inside the `config` block

```ruby
config do |cfg|
  cfg.provider :salesforce_flo, { client: Restforce.new(oauth_token: 'access_token', instance_url: 'instance url', api_version: '38.0') }
end
```

See the [RestForce gem](https://github.com/ejholmes/restforce) for information on setting up the client.

## Oauth Authentication Flow

The RestForce gem does not provide a mechanism for initiating the oauth authorization flow to retrieve the initial access token.  If you wish to authenticate with Oauth, you can use the Oauth wrapper

```ruby
config do |cfg|
cfg.provider :salesforce_flo, { client: SalesforceFlo::Authentication::OauthWrapper.new }
end
```

This enables the browser Oauth authorization flow.  It will open up the Salesforce authorization flow in the browser so that the user can authorize SalesforceFlo to make requests on the user's behalf.  It will also open up a local webserver on port 8000, which will accept the redirect at the end of the authorization flow so that SalesforceFlo can obtain the access token.

## Usage

Specify the commands you wish to run in the `register_command` block.  For example
```ruby
# Updates the `agf__ADM_Work__c` object, so that the `agf__Status__c` field is set to 'In Progress'
perform :salesforce_flo, :update_object, { sobject: 'agf__ADM_Work__c', name: work_id, fields: { agf__Status__c: 'In Progress' } }
```

## Contributing

1. Fork it (http://github.com/your-github-username/salesforce_flo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

>Copyright (c) 2017, Salesforce.com, Inc.
>All rights reserved.
>
>Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
>
>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
>
>* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
>
>* Neither the name of Salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
>
>THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
