RSS::OPDS
=========

[OPDS][opds] parser and maker.
OPDS(Open Publication Distribution System) is feed which syndicates information about ebooks.

[opds]:http://opds-spec.org/specs/opds-catalog-1-1

Why "RSS" rather than "Atom"? Because [class for Atom](http://apidock.com/ruby/v1_9_2_180/RSS/Atom) bundled with Ruby uses RSS namespace.

Installation
------------

Add this line to your application's Gemfile:

    gem 'rss-opds'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rss-opds

Usage
-----

### Parsing OPDS

    require 'open-uri'
    require 'rss/opds'
    
    opds = RSS::Parser.parse open(uri)
    opds.entries.each do |entry|
      price_elem = entry.links.select {|link| link.opds_price}.first
      puts price_elem
    end

If you need performance, install [rss-nokogiri][rss-nokogiri] gem and write `require 'rss/nokogiri'`
before calling `RSS::Parser.parse`.

[rss-nokogiri]: https://rubygems.org/gems/rss-nokogiri

### Making OPDS

    require 'rss/opds'
    
    recent = RSS::Maker.make('atom') {|maker|
      # ...
    }
    root = RSS::Maker.make('atom') {|maker|
      maker.channel.about = ...
      
      maker.items.add_feed recent, RSS::OPDS::RELATIONS['new']
      # equivalent to:
      # maker.items.new_item do |item|
      #   item.id = recent.id
      #   item.title = recent.title
      #   # ...
      # end
    }
    puts root # => output XMl including entry with 'new' sorting relation

Contributing
------------

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

* [RSS library documentation](http://www.cozmixng.org/~rwiki/?cmd=view;name=RSS+Parser)
* [OPDS specification](http://opds-spec.org/specs/)
* [Japanese translation](http://www.kzakza.com/opds/opds1_0_jpn.html) for OPDS version 1.0. That helped me very well, thank you!
* [OPDS validator](https://github.com/zetaben/opds-validator)
