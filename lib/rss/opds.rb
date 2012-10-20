require 'rss/atom'
require 'rss/dcterms'
require 'rss/atom/feed_history'
require 'rss/opds/version'

module RSS
  module Utils
    module TrueNil
      module_function
      def parse(value)
        if value === true
          value
        else
          /\Atrue\z/i.match(value.to_s) ? true : nil
        end
      end
    end
  end

  module BaseModel
    private

    def true_nil_attr_reader(*attrs)
      attrs.each do |attr|
        attr = attr.id2name if attr.kind_of?(Integer)
        module_eval(<<-EOC, __FILE__, __LINE__ + 1)
          attr_reader(:#{attr})
          def #{attr}?
            TrueNil.parse(@#{attr})
          end
        EOC
      end
    end

    def true_nil_writer(name, disp_name=name)
      module_eval(<<-EOC, __FILE__, __LINE__ + 1)
        def #{name}=(new_value)
          new_value = [true, 'true'].include?(new_value) ? 'true' : nil
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
        case type
        when :true_nil
          true_nil_writer name, disp_name
        else
          rss_def_corresponded_attr_writer name, type, disp_name
        end
      end

      alias rss_def_corresponded_attr_reader def_corresponded_attr_reader
      def def_corresponded_attr_reader(name, type=nil)
        case type
        when :true_nil
          true_nil_attr_reader name, type
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
    REGISTERED_RELATIONS = %w[
      alternate
      appendix
      archives
      author
      bookmark
      canonical
      chapter
      collection
      contents
      copyright
      current
      describedby
      disclosure
      duplicate
      edit
      edit-media
      enclosure
      first
      glossary
      help
      hosts
      hub
      icon
      index
      item
      last
      latest-version
      license
      lrdd
      monitor
      monitor-group
      next
      next-archive
      nofollow
      noreferrer
      payment
      predecessor-version
      prefetch
      prev
      previous
      prev-archive
      related
      replies
      search
      section
      self
      service
      start
      stylesheet
      subsection
      successor-version
      tag
      up
      version-history
      via
      working-copy
      working-copy-of
    ].reduce({}) {|relations, relation|
      relations[relation] = relation
      relations
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

      install_ns(PREFIX, URI)
      install_must_call_validator('opds', URI)
      install_get_attribute('currencycode', '')
      attr_accessor :value

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
         ['activeFacet', [:true_nil, :true_nil]]
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
        def price
          links.find {|link| link.opds_price}.opds_price
        end
      end
    end
  end
end
