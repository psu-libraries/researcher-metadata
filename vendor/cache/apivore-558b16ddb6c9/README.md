[![Build Status](https://travis-ci.org/westfieldlabs/apivore.svg?branch=master)](https://travis-ci.org/westfieldlabs/apivore)

[![Code Climate](https://codeclimate.com/github/westfieldlabs/apivore/badges/gpa.svg)](https://codeclimate.com/github/westfieldlabs/apivore)
# Apivore

Automatically tests your rails API against its OpenAPI (Swagger) description of end-points, models, and query parameters.

Currently supports and validates against OpenAPI 2.0, (see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md)

## Installation

To use Apivore, add the following to your Gemfile:

    gem 'apivore'
***WARNING:*** If apivore is listed in the Gemfile _above_ rspec then some issues, specifically `NameError: uninitialized constant RSpec::Mocks`, may arise when trying to run specs.

## Usage

Create a new request spec in spec/requests:
```ruby
require 'spec_helper'

RSpec.describe 'the API', type: :apivore, order: :defined do
  subject { Apivore::SwaggerChecker.instance_for('/swagger.json') }

  context 'has valid paths' do
    # tests go here
  end

  context 'and' do
    it 'tests all documented routes' do
      expect(subject).to validate_all_paths
    end
  end
end
```
using the path to your application's Swagger 2.0 documentation. The convention is `/swagger.json`.

This will validate the json against the Swagger 2.0 schema and allow you to add tests for each documented endpoint combination of a path, method, and expected response.

If your Swagger documentation contains a schema for the response model, the generated tests will test whether the response conforms to that model.

For paths that take parameters, listed in the Swagger docs like `/deals/{id}.json`, values need to be passed to Apivore to substitute in to access the responses generated by your test data.

This is accomplished by passing the params into the validates function.
```ruby
context 'has valid paths' do
  let(:params) { { "id" => 1 } }
  specify do
    expect(subject).to validate(
      :get, '/deals/{id}.json', 200, params
    )
  end

  # or alternatively

  it { is_expected.to validate( :get, '/deals/{id}.json', 200, params ) }
end
```
A query string can be specified with the `_query_string` key as follows:

```ruby
expect(subject).to validate(
  :get '/deals', 200, {"_query_string" => "title=Hello%20World&edition=3"}
)
```
Parameters in the query string are not validated or processed by Apivore in any way.

Post parameters can be specified with the `_data` key as follows:

```ruby
expect(subject).to validate(
  :post '/deals', 200, {"_data" => {'title' => 'Hello World'} }
)
```

HTTP headers can be specified via the `_headers` key:

```ruby
expect(subject).to validate(
  :get '/deals', 200, {"_headers" => {'accept' => 'application/json'} }
)
```

Your Swagger.json can be validated against additional custom schemata, for example to enforce organisation API documentation standards, by using the following syntax:

```ruby
it 'additionally conforms to a custom schema' do
  expect(subject).to conform_to("<your custom schema>.json")
end
```
We have included an example [here] (data/custom_schemata/westfield_api_standards.json). The file path to this custom schema is stored in `Apivore::CustomSchemaValidator::WF_SCHEMA`, if you wish to use it. 

Run the tests as part of your normal rspec test suite, e.g., `rake spec:requests`

## Useful Resources

* http://json-schema.org/
* https://github.com/OAI/OpenAPI-Specification
* https://github.com/ruby-json-schema/json-schema

## License

Copyright 2014 Westfield Labs Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

This project includes and makes use of the [OpenAPI (Swagger) 2.0 schema json](http://swagger.io/v2/schema.json) (Copyright 2016 The Linux Foundation. Released under the [Apache License](http://www.apache.org/licenses/LICENSE-2.0)) included here as `data/swagger_2.0_schema.json`

It also includes a copy of http://json-schema.org/draft-04/schema, included as `data/draft04_schema.json`. These schemata are included to prevent network resource fetching and speed up validation times considerably.

## Contributors

* Charles Horn (https://github.com/hornc)
* Leon Dewey (https://github.com/leondewey)
* Max Brosnahan (https://github.com/gingermusketeer)