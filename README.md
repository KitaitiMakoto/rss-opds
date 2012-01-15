RSS::OPDS
=========

TODO: Write a gem description

Why 'RSS'? Because [class for Atom](http://apidock.com/ruby/v1_9_2_180/RSS/Atom) bundled with Ruby uses RSS namespace.

## Installation

Add this line to your application's Gemfile:

    gem 'rss-opds'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rss-opds

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Merge Request

Development Plan
----------------

1. Parser for OPDS catalogs
2. Validation as OPDS
3. Utility methods like, for example, `#buy`(gets `link` element with `rel="acquisition/buy"`), `#price`(`opds:price` element) and so on
4. Maker for OPDS feeds and entries

References
----------

* [RSS liburary documentation](http://www.cozmixng.org/~rwiki/?cmd=view;name=RSS+Parser)
* [OPDS specification](http://opds-spec.org/specs/)
* [Japanese translation](http://www.kzakza.com/opds/opds1_0_jpn.html) for version 1.0. It helped me very well, thank you!
* [OPDS validator](https://github.com/zetaben/opds-validator)