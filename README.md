# JsonApiResourceConnecitons

Complex connection behaviour to sit on top of [JsonApiResource](http://github.com/avvo/json_api_resource) v2.0. This makes circuitbreaker connections default and enables cache flallbacks to when the server replies with anything other than a 404

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_api_resource_connecitons'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_api_resource_connecitons

And it should auto magically inject itself into `JsonApiResource::Resource`

## Usage

### CacheProcessor

TODO Explanation of what this is here

in your `config/json_api_resource.rb` you will need to set up the cache layer for the `CacheProcessor`

```ruby
module JsonApiResource

  # set up the cache lawyer for the cache processor
  module CacheProcessor
    CompressedCacheProcessor.cache = Rails.cache # or whatever
  end

  # set up the processor for the connections
  module Connections
    CachedCircuitbreakerServerConnection.cache_processor = JsonApiResource::CacheProcessor::CompressedCacheProcessor
    CacheConnection.cache_processor = JsonApiResource::CacheConnection::CompressedCacheProcessor
  end
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/json_api_resource_connecitons.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

