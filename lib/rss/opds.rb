require 'rss/atom'
require 'rss/dcterms'
require 'rss/atom/feed_history'
require 'rss/opds/version'

module RSS
  module Utils
    module TrueOther
      module_function
      def parse(value)
        if value === true
          value
        else
          /\Atrue\z/i.match(value.to_s) ? true : false
        end
      end
    end
  end

  module BaseModel
    private
    def true_other_attr_reader(*attrs)
      attrs.each do |attr|
        attr = attr.id2name if attr.kind_of?(Integer)
        module_eval(<<-EOC, __FILE__, __LINE__ + 1)
          attr_reader(:#{attr})
          def #{attr}?
            TrueOther.parse(@#{attr})
          end
        EOC
      end
    end

    def true_other_writer(name, disp_name=name)
      module_eval(<<-EOC, __FILE__, __LINE__ + 1)
        def #{name}=(new_value)
          new_value = 'true' if new_value === true
          @#{name} = new_value
        end
      EOC
    end
  end

  class Element
    class << self
      alias rss_def_corresponded_attr_writer def_corresponded_attr_writer
      def def_corresponded_attr_writer(name, type=nil, disp_name=nil)
        disp_name ||= name
        if type == :true_other
          true_other_writer name, disp_name
        else
          rss_def_corresponded_attr_writer name, type, disp_name
        end
      end

      alias rss_def_corresponded_attr_reader def_corresponded_attr_reader
      def def_corresponded_attr_reader(name, type=nil)
        if type == :true_other
          true_other_attr_reader name, type
        else
          rss_def_corresponded_attr_reader name, type
        end
      end
    end
  end

  module OPDS
    PREFIX = 'opds'
    URI = 'http://opds-spec.org/2010/catalog'
    TYPES = {
      'navigation' => 'application/atom+xml;profile=opds-catalog;kind=navigation',
      'acquisition' => 'application/atom+xml;profile=opds-catalog;kind=acquisition'
    }
    REGISTERED_RELATIONS = {
      'alternate'           => 'alternate',
      'appendix'            => 'appendix',
      'archives'            => 'archives',
      'author'              => 'author',
      'bookmark'            => 'bookmark',
      'canonical'           => 'canonical',
      'chapter'             => 'chapter',
      'collection'          => 'collection',
      'contents'            => 'contents',
      'copyright'           => 'copyright',
      'current'             => 'current',
      'describedby'         => 'describedby',
      'disclosure'          => 'disclosure',
      'duplicate'           => 'duplicate',
      'edit'                => 'edit',
      'edit-media'          => 'edit-media',
      'enclosure'           => 'enclosure',
      'first'               => 'first',
      'glossary'            => 'glossary',
      'help'                => 'help',
      'hosts'               => 'hosts',
      'hub'                 => 'hub',
      'icon'                => 'icon',
      'index'               => 'index',
      'item'                => 'item',
      'last'                => 'last',
      'latest-version'      => 'latest-version',
      'license'             => 'license',
      'lrdd'                => 'lrdd',
      'monitor'             => 'monitor',
      'monitor-group'       => 'monitor-group',
      'next'                => 'next',
      'next-archive'        => 'next-archive',
      'nofollow'            => 'nofollow',
      'noreferrer'          => 'noreferrer',
      'payment'             => 'payment',
      'predecessor-version' => 'predecessor-version',
      'prefetch'            => 'prefetch',
      'prev'                => 'prev',
      'previous'            => 'previous',
      'prev-archive'        => 'prev-archive',
      'related'             => 'related',
      'replies'             => 'replies',
      'search'              => 'search',
      'section'             => 'section',
      'self'                => 'self',
      'service'             => 'service',
      'start'               => 'start',
      'stylesheet'          => 'stylesheet',
      'subsection'          => 'subsection',
      'successor-version'   => 'successor-version',
      'tag'                 => 'tag',
      'up'                  => 'up',
      'version-history'     => 'version-history',
      'via'                 => 'via',
      'working-copy'        => 'working-copy',
      'working-copy-of'     => 'working-copy-of'
    }
    CATALOG_RELATIONS = {
      'start'         => 'start',
      'subsection'    => 'subsection',
      'new'           => 'http://opds-spec.org/sort/new',
      'popular'       => 'http://opds-spec.org/sort/popular',
      'featured'      => 'http://opds-spec.org/featured',
      'recommended'   => 'http://opds-spec.org/recommended',
      'shelf'         => 'http://opds-spec.org/shelf',
      'subscriptions' => 'http://opds-spec.org/subscriptions',
      'facet'         => 'http://opds-spec.org/facet',
      'crawlable'     => 'http://opds-spec.org/crawlable'
    }
    ENTRY_RELATIONS = {
      'acquisition' => 'http://opds-spec.org/acquisition',
      'open-access' => 'http://opds-spec.org/acquisition/open-access',
      'borrow'      => 'http://opds-spec.org/acquisition/borrow',
      'buy'         => 'http://opds-spec.org/acquisition/buy',
      'sample'      => 'http://opds-spec.org/acquisition/sample',
      'subscribe'   => 'http://opds-spec.org/acquisition/subscribe',
      'image'       => 'http://opds-spec.org/image',
      'thumbnail'   => 'http://opds-spec.org/image/thumbnail'
    }
    RELATIONS = Hash.new {|h, k|
      ENTRY_RELATIONS[k] or CATALOG_RELATIONS[k] or REGISTERED_RELATIONS[k] or
        raise KeyError, "Unsupported relation type: #{k.inspect}"
    }

    class Price < Element
      include Atom::CommonModel
      include Atom::ContentModel

      install_ns(PREFIX, URI)
      install_must_call_validator('opds', URI)
      install_get_attribute('currencycode', '')

      class << self
        def required_prefix
          PREFIX
        end

        def required_uri
          URI
        end

        def need_parent?
          true
        end
      end

      @tag_name = 'price'

      def full_name
        tag_name_with_prefix(PREFIX)
      end

      alias value content
      alias value= content=
    end

    BaseListener.install_class_name(URI, 'price', 'Price')
  end

  module Atom
    class Feed
      def navigation_feed?
        links.any? do |link|
          link.rel == 'self' and link.type == OPDS::TYPES['navigation']
        end
      end

      def acquisition_feed?
        links.any? do |link|
          link.rel == 'self' and link.type == OPDS::TYPES['acquisition']
        end
      end

      class Link < Element
        [
         ['facetGroup', nil],
         ['activeFacet', [:true_other, :true_other]]
        ].each do |name, type|
          disp_name = "#{OPDS::PREFIX}:#{name}"
          install_get_attribute(name, OPDS::URI, false, type, nil, disp_name)
          alias_method to_attr_name(name), name
          alias_method "#{to_attr_name(name)}=", "#{name}="
        end

        Price = OPDS::Price
        install_have_children_element 'opds_price', OPDS::URI, '*'
      end

      class Entry
        class Link
          Price = OPDS::Price
          install_have_children_element 'price', OPDS::URI, '*', 'opds_price'
        end

        def price
          links.find {|link| link.opds_price}.opds_price
        end
      end
    end
  end

  module Maker
    module Atom
      class Feed < RSSBase
        class Items
          # @todo consider whether method name is proper or not
          def add_feed(feed, relation, href=nil)
            self_link = maker.channel.links.find {|link| link.rel == RSS::OPDS::RELATIONS['self']}
            is_navigation_feed = self_link && self_link.type == RSS::OPDS::TYPES['navigation']
            raise TypeError, 'Only navigatfion feed can accept feed' unless is_navigation_feed
            raise ArgumentError, 'Only acquisition feed can be accepted' unless feed.acquisition_feed?
            new_item do |entry|
              [:title, :dc_description, :updated].each do |attr|
                val = feed.__send__(attr)
                entry.__send__("#{attr}=", val.content) if val
              end
              entry.links.new_link do |link|
                href = feed.links.find {|ln| ln.rel == RSS::OPDS::RELATIONS['self']}.href unless href
                link.href = href
                link.rel = relation
                link.type = RSS::OPDS::TYPES['acquisition']
              end
            end
          end
        end
      end
    end
  end
end
