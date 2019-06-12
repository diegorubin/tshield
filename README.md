TShield
=======

[![Build Status](https://travis-ci.org/diegorubin/tshield.svg)](https://travis-ci.org/diegorubin/tshield)
[![Ebert](https://ebertapp.io/github/diegorubin/tshield.svg)](https://ebertapp.io/github/diegorubin/tshield) [![Join the chat at https://gitter.im/diegorubin/tshield](https://badges.gitter.im/diegorubin/tshield.svg)](https://gitter.im/diegorubin/tshield?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## API mocks for development and testing
TShield is an open source proxy for mocks API responses.

* REST
* SOAP
* Session manager to separate multiple scenarios (success, error, sucess variation, ...)
* Lightweight
* MIT license
    
## Basic Usage
### Install

    gem install tshield

### Using

To run server execute this command

    tshield
    
Default port is **4567**
    

#### Config example

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

#### Admin UI

**[WIP]**

http://localhost:4567/admin/sessions

## Config options
```yaml
request:
  timeout: 8
  verify_ssl: <<value>>
domains:
  'http://my-soap-service:80':
    name: 'my-soap-service'
    headers:
      HTTP_AUTHORIZATION: Authorization
      HTTP_COOKIE: Cookie
    not_save_headers:
      - transfer-encoding
    cache_request: <<value>>
    filters: 
      - <<value>>
    excluded_headers:
      - <<value>>
    paths:
      - /Operation

  'http://localhost:9090':
    name: 'my-service'
    headers:
      HTTP_AUTHORIZATION: Authorization
      HTTP_COOKIE: Cookie
      HTTP_DOCUMENTID: DocumentId
    not_save_headers:
      - transfer-encoding
    paths:
      - /secure

  'http://localhost:9092':
    name: 'my-other-service'
    headers:
      HTTP_AUTHORIZATION: Authorization
      HTTP_COOKIE: Cookie
    not_save_headers:
      - transfer-encoding
    paths:
      - /users
```
**request**
* **timeout**: wait time for real service in seconds
* **verify_ssl**: <<some_description>>

**domain**
* Define Base URI of service
* **name**: Name to identify the domain in the generated files
* **headers**: <<some_description>>
* **not_save_headers**: <<some_description>>
* **cache_request**: <<some_description>>
* **filters**: <<some_description>>
* **excluded_headers**: <<some_description>>
* **paths**: Paths list of all services that will be called. Used to filter what domain will "receive the request"

## Manage Sessions

You can use TShield sessions to separate multiple scenarios for your mocks

By default TShield save request/response into 

    requests/<<domain_name>>/<<resource_with_param>>/<<http_verb>>/<<index_based.content and json>>
    
If you start a session a folder with de **session_name** will be placed between **"requests/"** and **"<<domain_name>>"**

### Start TShield session
**Start new or existing session**

_POST_ to http://localhost:4567/sessions?name=<<same_name>>

```
curl -X POST \
  'http://localhost:4567/sessions?name=my_valid'
```

### Stop TShield session
**Stop current session**

_DELETE_ to http://localhost:4567/sessions

```
curl -X DELETE \
  http://localhost:4567/sessions
```

## Custom controllers

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

## Samples
#### Basic sample for a client app requesting a server API
[examples/client-api-nodejs](examples/client-api-nodejs)
#### Basic sample for componente/integration test
**[WIP]**

## Setup for local development

### Build
**[WIP]**
### Test
**[WIP]**
