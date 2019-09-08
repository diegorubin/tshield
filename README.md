TShield
=======

[![Build Status](https://travis-ci.org/diegorubin/tshield.svg)](https://travis-ci.org/diegorubin/tshield)
[![Coverage Status](https://coveralls.io/repos/github/diegorubin/tshield/badge.svg?branch=master)](https://coveralls.io/github/diegorubin/tshield?branch=master)
[![SourceLevel](https://app.sourcelevel.io/github/diegorubin/tshield.svg)](https://app.sourcelevel.io/github/diegorubin/tshield)
[![Join the chat at https://gitter.im/diegorubin/tshield](https://badges.gitter.im/diegorubin/tshield.svg)](https://gitter.im/diegorubin/tshield?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Gem Version](https://badge.fury.io/rb/tshield.svg)](https://badge.fury.io/rb/tshield)

## API mocks for development and testing
TShield is an open source proxy for mocks API responses.

* REST
* SOAP
* Session manager to separate multiple scenarios (success, error, sucess variation, ...)
* Lightweight
* MIT license
    
#### Table of Contents:

* [Basic Usage](#basic-usage)
* [Config options for Pattern Matching](#config-options-for-pattern-matching)
* [Config options for VCR](#config-options-for-vcr)
* [Manage Sessions](#manage-sessions)
* [Custom controllers](#custom-controllers)
* [Features](#features)
* [Examples](#examples)
* [Contributing](#contributing)
    
## Basic Usage
### Install

    gem install tshield

### Using

To run server execute this command

    tshield
    
Default port is `4567`

#### Command Line Options

* __-port__: Overwrite default port (4567)
* __-help__: Show all command line options

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

## Config options for Pattern Matching

An example of file to create a stub:

All files should be in `matching` directory.
Each file should be a valid JSON array of objects and each object must contain
at least the following attributes:

* __method__: a http method.
* __path__: url path.
* __response__: object with response data. Into session can be used an array of objects to return different responses like vcr mode. See example: [multiples_response.json](https://github.com/diegorubin/tshield/blob/master/component_tests/matching/examples/multiple_response.json)

Response must be contain the following attributes:

* __headers__: key value object with expected headers to match. In the evaluation process
  this stub will be returned if all headers are in request. 
* __status__: integer used http status respose.
* __body__: content to be returned.

Optional request attributes:

* __headers__: key value object with expected headers to match. In the evaluation process
  this stub will be returned if all headers are in request. 
* __query__: works like headers but use query params.

__Important__: If VCR config conflicts with Matching config Matching will be
used. Matching config have priority.

### Session Configuration

To register stub into a session create an object with following attributes:

* __session__: name of session.
* __stubs__: an array with objects described above.

### Example of matching configuration

```json
[{
    "method": "GET",
    "path": "/matching/example",
    "query": {
      "user": 123
    },
    "response": {
      "body": "matching-example-response-with-query",
      "headers": {},
      "status": 200
    }
  },
  {
    "method": "GET",
    "path": "/matching/example",
    "response": {
      "body": "matching-example-response",
      "headers": {},
      "status": 200
    }
  },
  {
    "method": "POST",
    "path": "/matching/example",
    "headers": {
      "user": "123"
    },
    "response": {
      "body": "matching-example-response-with-headers",
      "headers": {},
      "status": 200
    }
  },
  {
    "method": "POST",
    "path": "/matching/example",
    "response": {
      "body": "matching-example-response-with-post",
      "headers": {},
      "status": 200
    }
  },
  {
    "session": "example-session",
    "stubs": [{
      "method": "GET",
      "path": "/matching/example",
      "response": {
        "body": "matching-example-response-in-session",
        "headers": {},
        "status": 200
      }
    }]
  }
]
```

## Config options for VCR
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
* **verify_ssl**: ignores invalid ssl if false

**domain**
* Define Base URI of service
* **name**: Name to identify the domain in the generated files
* **headers**: github-issue #17
* **not_save_headers**: List of headers that should be ignored in generated file
* **skip_query_params**: List of query params that should be ignored in generated file
* **cache_request**: <<some_description>>
* **filters**: Implementation of before or after filters used in domain requests
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

## Features

Description of some tshield features can be found in the features directory.
This features files are used as base for the component tests.

## Examples
#### Basic example for a client app requesting an API
[examples/client-api-nodejs](examples/client-api-nodejs)

#### Basic example for component/acceptance test
**[WIP]**

## Contributing
[Hacking or Contributing to TShield](CONTRIBUTING.md)
