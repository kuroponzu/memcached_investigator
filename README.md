# MemcachedInvestigator

A simple memcached client for research, debugging

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add memcached_investigator

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install memcached_investigator

## Usage

```
client = MemcachedInvestigator::Client.new
client.add(key: "cache",value: "cached")
=> "STORED"
client.metadump_all
"key=cache exp=1651903111 la=1651838152 cas=39 fetch=no cls=1 size=70"
"END"
=> nil
client.flush_all
=> "OK"
client.metadump_all
"END"
=> nil
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Start up memcached

```
 docker run --rm -p 11211:11211  memcached:1.6.15-bullseye
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/memcached_investigator.
