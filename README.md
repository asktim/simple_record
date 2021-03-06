# SimpleRecord

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/simple_record`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_record'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_record

## Usage

```ruby

class Article
  include Schema

  # Schema Definition
  attribute 'name', :string
  attribute 'description', :text
  attribute 'read_count', :integer
end

# Creates datatable
Article.dt_create

# Drops datatable
Article.dt_drop

Article.new('name' => 'Cacher in the rye')

Article.create

Article.where('name = ?', 'Cacher in the rye').where('id > 10')
# => Enumerator for Article objects

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/asktim/simple_record.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
