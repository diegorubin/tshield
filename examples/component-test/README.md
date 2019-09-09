# Component tests example

Example using tshield as api mock for a web application component test using Ruby, Cucumber and Capybara

## Getting Started

### Prerequisites

This example use Node.js, Ruby and ChromeDriver

### Installing

#### App project (app)

##### Project Installation
Run the following command to prepare your environment:

```
  npm i
```

##### Start application
To run with tshield mock server run the following command

```
  npm run start-mock
```

To run without mock run the following command

```
  npm run start
```

###### Other configs

To run application without mocks you need to provide valid API keys to start application by this env vars:

*   MARVEL_API_PRIVATE_KEY
*   MARVEL_API_PUBLIC_KEY
*   TENOR_API_KEY

#### Component test project (tests/components)

##### Install bundler
To get started, install the bundler:

```
  gem install bundler
```

##### Project Installation
Then you should be able to run the following command to prepare your environment:

```
  bundle install
```

##### Start tshield
Now run tshield to start mock server

```
  tshield
```

### Run tests

#### Start application with mocks enabled (_./app dir_)
```
  npm run start-mock
```
#### Start mock (_./app/tests/components dir_)
```
  tshield
```
#### Run cucumber
```
  cucumber
```
