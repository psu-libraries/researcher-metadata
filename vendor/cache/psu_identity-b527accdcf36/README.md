[![CircleCI](https://circleci.com/gh/psu-libraries/psu_identity.svg?style=svg)](https://circleci.com/gh/psu-libraries/psu_identity)
[![Maintainability](https://api.codeclimate.com/v1/badges/4add85571dd35c111426/maintainability)](https://codeclimate.com/github/psu-libraries/psu_identity/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/4add85571dd35c111426/test_coverage)](https://codeclimate.com/github/psu-libraries/psu_identity/test_coverage)

# PsuIdentity

A wrapper for Penn State's search service API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'psu_identity'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install psu_identity

## Usage

Add this to the top of your code:

    require 'psu_identity'
    
To query the search service by name:

    # Takes a hash as parameter with 'text:' as the key
    
    PsuIdentity::SearchService::Client.new.search(text: 'Jimmy Tester')
    
***This will return an array of PsuIdentity::SearchService::Person objects matching the query***

To query the search service by userid:

    # Takes a string as a parameter
    
    PsuIdentity::SearchService::Client.new.userid('abc123')
    
***This will return a single PsuIdentity::SearchService::Person object matching the query***

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/psu_identity. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/psu_identity/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PsuIdentity project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/psu_identity/blob/master/CODE_OF_CONDUCT.md).
