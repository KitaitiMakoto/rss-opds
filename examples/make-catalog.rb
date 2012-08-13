require 'rss'
require 'rss/opds'

Book = Struct.new 'Book',
                  :title, :author, :summary, :updated, :link, :popularity

def main
  puts root
  puts popular
end

def root
  RSS::Maker.make('atom') {|maker|
    maker.channel.about = 'http://example.net/'
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
    maker.items.new_item do |entry|
      entry.links.new_link do |link|
        link.href = 'http://example.net/new.opds'
        link.type = RSS::OPDS::TYPES['acquisition']
      end
      entry.title = 'Example New Books'
      entry.updated = '2012-08-14T04:23:00'
      entry.summary = 'New books in this site'
    end
  }
end

def popular
  RSS::Maker.make('atom') do |maker|
    maker.channel.about = 'http://example.net/'
    maker.channel.title = 'Example Popular Catalog'
    maker.channel.description = 'Popular books in this site'
    maker.channel.links.new_link do |link|
      link.href = 'http://example.net/popular.opds'
      link.rel = 'self'
      link.type = RSS::OPDS::TYPES['acquisition']
    end
    maker.channel.links.new_link do |link|
      link.href = 'http://example.net/root.opds'
      link.rel = 'start'
      link.type = RSS::OPDS::TYPES['navigation']
    end
    maker.channel.updated = '2012-07-31T00:00:00'
    maker.channel.author = 'KITAITI Makoto'

    books.sort_by {|book| book.popularity}.reverse_each do |book|
      maker.items.new_item do |entry|
        entry.title = book.title
        entry.updated = book.updated
        entry.summary = book.summary
        entry.link = book.link
      end
    end
  end
end

def books
  [
   Book.new('book1', 'author1', 'summary1', Time.gm(2012, 8, 14, 3), 'http://example.net/book/book1', 1),
   Book.new('book2', 'author2', 'summary2', Time.gm(2012, 8, 10, 14), 'http://example.net/book/book2', 2),
   Book.new('book3', 'author3', 'summary3', Time.gm(2012, 6, 30, 12), 'http://example.net/book/book3', 3)
  ]
end

if $0 == __FILE__
  main
end
