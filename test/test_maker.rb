require_relative 'helper'
require 'rss/maker/opds'

class TestMaker < TestOPDS
  def test_set_price
    feed = RSS::Maker.make('atom') {|maker|
      %w[id author title].each do |property|
        maker.channel.send "#{property}=", property
      end
      maker.channel.updated = Time.now

      maker.items.new_item do |entry|
        entry.id = 'entry id'
        entry.title = 'entry title'
        entry.author = 'entry author'
        entry.updated = Time.now

        entry.links.new_link do |link|
          link.href = 'uri/to/purchase'
          link.opds_prices.new_opds_price do |price|
            price.value = 100
            price.currencycode = 'JPY'
          end
        end
      end
    }
    doc = REXML::Document.new(feed.to_s)
    assert_not_empty REXML::XPath.match(doc, "//*[namespace-uri()='http://opds-spec.org/2010/catalog']")
  end

  def test_set_active_facet
    feed = RSS::Maker.make('atom') {|maker|
      %w[id author title].each do |property|
        maker.channel.send "#{property}=", property
      end
      maker.channel.updated = Time.now

      maker.items.new_item do |entry|
        entry.id = 'entry id'
        entry.title = 'entry title'
        entry.author = 'entry author'
        entry.updated = Time.now

        entry.links.new_link do |link|
          link.href = 'uri/to/facet'
          link.activeFacet = true
        end
      end
    }

puts feed

    doc = REXML::Document.new(feed.to_s)
    links = REXML::XPath.match(doc, "//[@opds:activeFacet]")
    assert_not_empty links
    assert_equal 'true', links.first.attributes['opds:activeFacet']
  end

  def test_set_negative_facet
    # negative(not have "true" value) facet element shoud not present in document
    assert false
  end

  def test_navigation_feed_accepts_aqcuisition_feed_as_item
    catalog_root = nil
    assert_nothing_raised do
      catalog_root = RSS::Maker.make('atom') {|maker|
        maker.channel.about = 'http://example.net/'
        maker.channel.title = 'Example Catalog Root'
        maker.channel.description = 'Sample OPDS'
        maker.channel.links.new_link do |link|
          link.href = 'http://example.net/root.opds'
          link.rel = RSS::OPDS::RELATIONS['self']
          link.type = RSS::OPDS::TYPES['navigation']
        end
        maker.channel.links.new_link do |link|
          link.href = 'http://example.net/root.opds'
          link.rel = RSS::OPDS::RELATIONS['start']
          link.type = RSS::OPDS::TYPES['navigation']
        end
        maker.channel.updated = '2012-08-14T05:30:00'
        maker.channel.author = 'KITAITI Makoto'

        maker.items.add_feed recent, RSS::OPDS::RELATIONS['new']
        # maker.items.add_new recent
      }
    end
  end

  def test_utility_to_add_link_to_catalog_root
    # test Maker::Atom::Feed::Items#add_root_link
    pend
  end

  def root
    RSS::Maker.make('atom') {|maker|
      maker.channel.about = 'http://example.net/'
      maker.channel.title = 'Example Catalog Root'
      maker.channel.description = 'Sample OPDS'
      maker.channel.links.new_link do |link|
        link.href = 'http://example.net/root.opds'
        link.rel = RSS::OPDS::RELATIONS['self']
        link.type = RSS::OPDS::TYPES['navigation']
      end
      maker.channel.links.new_link do |link|
        link.href = 'http://example.net/root.opds'
        link.rel = RSS::OPDS::RELATIONS['start']
        link.type = RSS::OPDS::TYPES['navigation']
      end
      maker.channel.updated = '2012-08-14T04:23:00'
      maker.channel.author = 'KITAITI Makoto'

      maker.items.new_item do |entry|
        entry.links.new_link do |link|
          link.href = 'http://example.net/popular.opds'
          link.rel = RSS::OPDS::RELATIONS['popular']
          link.type = RSS::OPDS::TYPES['acquisition']
        end
        entry.title = 'Example Popular Books'
        entry.updated = '2012-07-31T00:00:00'
        entry.summary = 'Popular books in this site'
      end
      maker.items.new_item do |entry|
        entry.links.new_link do |link|
          link.href = 'http://example.net/new.opds'
          link.rel = RSS::OPDS::RELATIONS['new']
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
        link.rel = RSS::OPDS::RELATIONS['self']
        link.type = RSS::OPDS::TYPES['acquisition']
      end
      maker.channel.links.new_link do |link|
        link.href = 'http://example.net/root.opds'
        link.rel = RSS::OPDS::RELATIONS['start']
        link.type = RSS::OPDS::TYPES['navigation']
      end
      maker.channel.updated = '2012-07-31T00:00:00'
      maker.channel.author = 'KITAITI Makoto'

      popular_books.each do |book|
        maker.items.new_item do |entry|
          entry.title = book.title
          entry.updated = book.updated
          entry.summary = book.summary
          entry.link = book.link
        end
      end
    end
  end

  def recent
    RSS::Maker.make('atom') do |maker|
      maker.channel.about = 'http://example.net/'
      maker.channel.title = 'Example New Catalog'
      maker.channel.description = 'New books in this site'
      maker.channel.links.new_link do |link|
        link.href = 'http://example.net/new.opds'
        link.rel = 'self'
        link.type = RSS::OPDS::TYPES['acquisition']
      end
      maker.channel.links.new_link do |link|
        link.href = 'http://example.net/root.opds'
        link.rel = RSS::OPDS::RELATIONS['start']
        link.type = RSS::OPDS::TYPES['navigation']
      end
      maker.channel.updated = '2012-08-14T04:23:00'
      maker.channel.author = 'KITAITI Makoto'

      new_books.each do |book|
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

  def popular_books
    books.sort_by {|book| book.popularity}.reverse_each
  end

  def new_books
    books.sort_by {|book| book.updated}.reverse_each
  end
end
