# Faraday::Http

[![Gem Version](https://badge.fury.io/rb/faraday-http.svg)](https://rubygems.org/gems/faraday-http)
[![GitHub Actions CI](https://github.com/lostisland/faraday-http/workflows/CI/badge.svg)](https://github.com/lostisland/faraday-http/actions?query=workflow%3ACI)

This gem is a [Faraday][faraday] adapter for the [http.rb gem][http-gem].

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faraday-http'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install faraday-http

## Usage

Configure your Faraday connection to use this adapter instead of the default one:

```ruby
connection = Faraday.new(url, conn_options) do |conn|
  # Your other middleware goes here...
  conn.adapter :http
end
```

For more information on how to setup your Faraday connection and adapters usage,
please refer to the [Faraday Website][faraday-website].

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then create a GitHub Releases entry, which will create a git tag for the version,
and push the `.gem` file to [rubygems.org] via the GitHub Actions Workflow `publish.yml`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lostisland/faraday-http.
This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the [Contributor Covenant][covenant] code of conduct.

## License

The gem is available as open source under the terms of the [MIT License][mit-license].

## Code of Conduct

This project is intended to be a safe, welcoming space for collaboration.
Everyone interacting in the Faraday::Http project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of conduct].

[code-of-conduct]:  https://github.com/lostisland/faraday-http/blob/master/.github/CODE_OF_CONDUCT.md
[covenant]:         http://contributor-covenant.org
[faraday]:          https://github.com/lostisland/faraday
[faraday-website]:  https://lostisland.github.io/faraday
[http-gem]:         https://github.com/httprb/http
[mit-license]:      https://opensource.org/licenses/MIT
[rubygems.org]:     https://rubygems.org
