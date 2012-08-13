require 'rss'
require 'rss/opds'

def main
  root = RSS::Maker.make('atom') {|maker|
    maker.channel.about = 'http://example.net/root.opds'
    maker.channel.title = 'Example Catalog Root'
    maker.channel.description = 'Sample OPDS'
    maker.channel.links.new_link do |link|
      link.href = 'http://example.net/root.opds'
      link.rel = 'self'
      link.type = RSS::OPDS::TYPES['navigation']
    end
    maker.channel.links.new_link do |link|
      link.href = 'http://example.net/root.opds'
      link.rel = 'start'
      link.type = RSS::OPDS::TYPES['navigation']
    end
    maker.channel.updated = '2012-08-14T04:23:00'
    maker.channel.author = 'KITAITI Makoto'

    maker.items.new_item do |entry|
      entry.links.new_link do |link|
        link.href = 'http://example.net/popular.opds'
        link.type = RSS::OPDS::TYPES['acquisition']
      end
      entry.title = 'Example Popular Books'
      entry.updated = '2012-07-31T00:00:00'
      entry.summary = 'Popular books in this site'
    end
  }

  puts root
end

if $0 == __FILE__
  main
end

