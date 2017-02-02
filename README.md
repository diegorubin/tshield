TShield
=======

## Install

    gem install tshield

## Using

To run server execute this command

    tshield

### Config example

Before run `tshield` command is necessary to create config file.
This is an example of `config/tshield.yml`

```yaml
request:
  # wait time for real service
  timeout: 8

# list of domains that will be used
domains:
  # Base URI of service
  'https://service.com':
    # name to identify the domain in the generated files
    name: 'service'

    # paths list of all services that will be called
    paths:
      - /users
```

### Custom controllers

All custom controller should be created in `controllers` directory.

Example of controller file called `controllers/foo_controller.rb`

```ruby
require 'json'
require 'tshield/controller'

module FooController
  include TShield::Controller
  action :tracking, methods: [:post], path: '/foo'

  module Actions
    def tracking(params, request)
      status 201
      headers 'Content-Type' => 'application/json'
      {message: 'foo'}.to_json
    end
  end
end
```


