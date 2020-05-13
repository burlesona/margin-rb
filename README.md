# MarginRB

This is a Ruby parser for Alex Gamburg's "Margin" markup language.

See https://margin.love/ for the documentation,
and https://github.com/gamburg/margin for Alex's implementation.

This should be considered an early Alpha, as many details in the
spec are still being worked out.

## Divergence from Alex's Implementation

To eliminate some ambiguities in the spec and keep the parser
simple, this implementation refines the specification for Margin
as follows:

1. Every valid item must end in a newline, which means the document itself
   must end in a newline if there is an item on the last line.
2. Items can be one of two types, "item" or "task." To represent this I added
   a 'type' field on the Item's JSON representation. This is mostly informational
   and avoids users of the parsed data needing to do additional checks
   to figure out if an item is a task or not.
3. Items which are tasks have a boolean `done` field indicating whether they are done.
4. The `value` field on each item is cleaned of any leading or trailing decoration,
   including whitespace. Thus, the `value` field of a Task does not include the leading
   "checkbox" annotation.
5. Annotations are represented as objects with a required `value` and an optional `key`.
   In Alex's implementation the key and value of what he calls an "index"
   (an annotation with a colon in it) are not machine parsed.
6. If the `value` of an annotation is strictly numeric, it is parsed into a number,
   not a string.

## Installation

Margin requires Ruby >= 2.6.x.

To use it directly:

```sh
$ gem install margin
```

In an application, add this line to your application's Gemfile:

```ruby
gem 'margin'
```

And then execute:

```sh
$ bundle install
```

## Usage

Right this minute there's not much you can do with it except load it into
a repl and poke it. As an example, supposing you have a file `example.margin`
in your working directory, you can then run `bin/console` and play with it in
IRB like so:

```ruby
d = Margin::Document.from_margin(File.read('example.margin'))
d.root #=> returns a Margin::Item for the root
d.to_json #=> returns a JSON representation of the parsed tree
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Development Plans

I'm not sure! I saw Alex's ShowHN introducing Margin to the world and thought it looked like a fun parser to crank out. I thought it would take a couple hours... a couple hours turned out to be more like 8, haha :D.

I'm having fun poking at this for now and discussing the spec on the main Margin repo. I'll probably add a CLI that will make this more useful. After that, I'm not sure. At that point it's sort of done?

## Contributing

Feedback, bug reports, and pull requests are welcome on GitHub at https://github.com/burlesona/margin.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
