TShield
=======

[![Build Status](https://travis-ci.org/diegorubin/tshield.svg)](https://travis-ci.org/diegorubin/tshield)
[![Coverage Status](https://coveralls.io/repos/github/diegorubin/tshield/badge.svg?branch=master)](https://coveralls.io/github/diegorubin/tshield?branch=master)
[![Gem Version](https://badge.fury.io/rb/tshield.svg)](https://badge.fury.io/rb/tshield)
![TShield Publish](https://github.com/diegorubin/tshield/workflows/TShield%20Publish/badge.svg)

## API mocks for development and testing
TShield is an open source proxy for mocks API responses.

*   REST
*   SOAP
*   Session manager to separate multiple scenarios (success, error, sucess variation, ...)
*   gRPC [EXPERIMENTAL]
*   Lightweight
*   MIT license

## Table of Contents

*   [Basic Usage](#basic-usage)
*   [Config options for Pattern Matching](#config-options-for-pattern-matching)
*   [Config options for VCR](#config-options-for-vcr)
*   [Manage Sessions](#manage-sessions)
*   [Custom controllers](#custom-controllers)
*   [Features](#features)
*   [Examples](#examples)
*   [Contributing](#contributing)

## Basic Usage
### Install

    gem install tshield

### Using

To run server execute this command

    tshield

Default port is `4567`

#### Command Line Options

*   **-port**: Overwrite default port (4567)
*   **-help**: Show all command line options

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

**Windows Compatibility:** If you need to use Tshield in Windows SO, change the config file and set the windows_compatibility to true.

Eg:
```yaml
windows_compatibility: true
request:
  # wait time for real service
  timeout: 8
...
```

## Config options for Pattern Matching

An example of file to create a stub:

All files should be in `matching` directory.
Each file should be a valid JSON array of objects and each object must contain
at least the following attributes:

*   **method**: a http method.
*   **path**: url path. This attribute accept regex, see example in [regex.json](https://github.com/diegorubin/tshield/blob/master/component_tests/matching/examples/regex.json)
*   **response**: object with response data. Into session can be used an array of objects to return different responses like vcr mode. See example: [multiples_response.json](https://github.com/diegorubin/tshield/blob/master/component_tests/matching/examples/multiple_response.json). External file can be used as body content, see example in [file.json](https://github.com/diegorubin/tshield/blob/master/component_tests/matching/examples/file.json).

Response must be contain the following attributes:

*   **headers**: key value object with expected headers to match. In the evaluation process
this stub will be returned if all headers are in request. 
*   **status**: integer used http status respose.
*   **body**: content to be returned.

Optional request attributes:

*   **headers**: key value object with expected headers to match. In the evaluation process
this stub will be returned if all headers are in request. 
*   **query**: works like headers but use query params.

Optional response attributes:

*   **delay**: integer that represents time in seconds that the response will be delayed to return

**Important**: If VCR config conflicts with Matching config Matching will be
used. Matching config have priority.

### Session Configuration

To register stub into a session create an object with following attributes:

*   **session**: name of session.
*   **stubs**: an array with objects described above.

### Example of HTTP matching configuration

```json
[
  {
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
        "delay": 5,
        "body": "matching-example-response-in-session",
        "headers": {},
        "status": 200
      }
    }]
  }
]
```

## Config options for HTTP VCR
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
    send_header_content_type: true  
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
    delay:
      '/secure': 10

  'http://localhost:9092':
    name: 'my-other-service'
    headers:
      HTTP_AUTHORIZATION: Authorization
      HTTP_COOKIE: Cookie
    not_save_headers:
      - transfer-encoding
    paths:
      - /users
    delay:
      '/users': 5
```
**request**
*   **timeout**: wait time for real service in seconds
*   **verify_ssl**: ignores invalid ssl if false

**domain**
*   Define Base URI of service
*   **name**: Name to identify the domain in the generated files
*   **headers**: github-issue #17
*   **send_header_content_type**: Boolean domain config to send header 'Content-Type' when requesting this domain  
*   **not_save_headers**: List of headers that should be ignored in generated file
*   **skip_query_params**: List of query params that should be ignored in generated file
*   **cache_request**: <<some_description>>
*   **filters**: Implementation of before or after filters used in domain requests
*   **excluded_headers**: <<some_description>>
*   **paths**: Paths list of all services that will be called. Used to filter what domain will "receive the request"
*   **delay**: List of times in seconds that the response will be delayed to return for an specific path defined above

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
### Append secondary TShield session
**Append session. Secondary sessions will used only for read content in VCR mode, writes will be do in the main session. Append only works if exists a current session setted.**

_POST_ to http://localhost:4567/sessions?name=<<same_name>>

```
curl -X POST \
  'http://localhost:4567/sessions/append?name=my_valid'
```

## [Experimental] Config options for gRPC

```yaml
grpc:
  port: 5678
  proto_dir: 'proto'
  services:
    'helloworld_services_pb': 
      module: 'Helloworld::Greeter'
      hostname: '0.0.0.0:50051'
```


### Not Implemented Yet 

- Matching

### Configuration

First, generate ruby files from proto files. Use `grpc_tools_ruby_protoc`
present in the gem `grpc-tools`. Example:

`grpc_tools_ruby_protoc -I proto --ruby_out=proto --grpc_out=proto proto/<INPUT>.proto`

Call example in component_tests using [grpcurl](https://github.com/fullstorydev/grpcurl):

`grpcurl -plaintext -import-path component_tests/proto -proto helloworld.proto  -d '{"name": "teste"}' localhost:5678 helloworld.Greeter/SayHello`

### Using in VCR mode

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

#### Basic example for component/acceptance test using tshield sessions
[examples/component-test](examples/component-test)

## Contributing
[Hacking or Contributing to TShield](CONTRIBUTING.md)
