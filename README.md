# JsonApiResourceConnections

Complex connection behaviour to sit on top of [JsonApiResource](http://github.com/avvo/json_api_resource) v2.0. This makes circuitbreaker connections default and enables cache fallbacks to when the server replies with anything other than a 404

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_api_resource_connections'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_api_resource_connections

And it should auto magically inject itself into `JsonApiResource::Resource`

## Usage

Once the gem is included, it automatically injects its code into all `JsonApiResource`s, giving them default circuitbreaker connections. There are 3 major components and a couple handy helpers.

### Helpers

#### cache_fallback( *actions )

Enables retreival of data from cache if the server connection fails. Passing no actions will enable cache fallbacks for everything. 

Requires caching to be enabled as described in [setup](#setup).

#### try_cache_first( *actions )

Will force the resource to try to fetch the data requested from the cache first, before it tries to hit the server. Passing no actions will force trying caching for everything.

Requires caching to be enabled as described in [setup](#setup).

#### cacheless_find( id )

If you are using `try_cache_first` and need to bypass it for `find`, this is the way to do it.

#### cacheless_where( opts = {} )

If you are using `try_cache_first` and need to bypass it for `where`, this is the way to do it.

### Components

#### CacheProcessor

Cache Processor is the component that handles caching. `CompressedCacheProcessor` caches results in two pieces: the actual object and the ids for the action. So your `Snack.search(q: "cheezbergher")` call will cache as 
``` ruby
'snack/search/q=>"cheezbergher"' => `[1, 2, 3, 4]`

# and

"snack/search/id:1" => {id: 1, ... }
"snack/search/id:2" => {id: 2, ... }
...
```

When no id is present in the response, the full response will be cached.

#### CachedCircuitbreakerServerConnection

New default connection. Calls the server, but if the request fails, it will drop all subsequent calls for 30 seconds. Failure is defined as any non-404 error; a 500 server error or any exception in the code will trip the circuitbreaker.

If the request succeeds, it will try to cache the result using its cache_processor. If none is set up, no caching will occur. 

See [setup](#setup) for enabling caching.

#### CacheConnection

Given an action, will try to fetch results from the cache via cache_processor. Is used as both fallback and cache first connection. 

Requires caching to be enabled as described in [setup](#setup).

## Setup

In your `config/json_api_resource.rb` you will need to set up the cache layer for the `CacheProcessor`

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

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avvo]/json_api_resource_connections.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

