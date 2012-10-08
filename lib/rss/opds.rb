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

      class Link
        [
         ['facetGroup', nil],
         ['activeFacet', [:true_other, :true_other]]
        ].each do |name, type|
          disp_name = "#{OPDS::PREFIX}:#{name}"
          install_get_attribute(name, OPDS::URI, false, type, nil, disp_name)
          alias_method to_attr_name(name), name
          alias_method "#{to_attr_name(name)}=", "#{name}="
        end
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
end
