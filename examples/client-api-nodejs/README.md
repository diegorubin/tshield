# Client API example with Node.js

Example using tshield as offline api mock

## Getting Started

### Prerequisites

This example use Node.js and Ruby

### Installing

#### Mock server project (mock-server)

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

#### Client API project (client-api)

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

##### Testing requests

After start mock-server and client-api access swagger interface for testing requests:

http://localhost:8080/api-docs

For this example the valid filters are:

- hulk
- spider-man
- spider man

For other filters you need to config Marvel and Tenor API keys for valid authorization.

After get valid API keys start application with this env vars:

- MARVEL_API_PRIVATE_KEY
- MARVEL_API_PUBLIC_KEY
- TENOR_API_KEY

**Example**:

```
MARVEL_API=http://localhost:4567 \
TENOR_API=http://localhost:4567 \
MARVEL_API_PRIVATE_KEY=<<private-key>> \
MARVEL_API_PUBLIC_KEY=<<pubic-key>> \
TENOR_API_KEY=<<key>> \
npm run start
```
