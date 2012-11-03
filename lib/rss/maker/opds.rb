require 'rss/maker'
require 'rss/opds'

module RSS
  module Maker
    module OPDS
      module LinkBase
        class << self
          def included(base)
            super
            base.class_eval(<<-EOC, __FILE__, __LINE__ + 1)
              %w[facetGroup activeFacet].each do |attr|
                def_other_element attr
              end
              def_classed_elements 'opds_price', 'value', 'Prices'

              # @note Defined to prevent NoMethodError
              def setup_opds_prices(feed, current)
              end

              def to_feed(feed, current)
                super # AtomLink#to_feed
                opds_prices.to_feed(feed, current.links.last)
              end
            EOC
          end
        end

        class Prices < Base
          def_array_element 'opds_price', nil, 'Price'

          class Price < Base
            %w[value currencycode].each do |attr|
              attr_accessor attr
            end

            def to_feed(feed, current)
              price = ::RSS::OPDS::Price.new
              price.value = value
              price.currencycode = currencycode
              current.opds_prices << price
              set_parent price, current
              setup_other_elements(feed)
            end

            private

            def required_variable_names
              %w[currencycode]
            end
          end
        end
      end
    end

    module Atom
      class Feed < RSSBase
        class Items < ItemsBase
          class Item < ItemBase
            class Links < LinksBase
              class Link < LinkBase
                include OPDS::LinkBase
              end
            end
          end

          def add_relation(feed, relation, href=nil)
            self_link = maker.channel.links.find {|link| link.rel == RSS::OPDS::RELATIONS['self']}
            is_navigation_feed = self_link && self_link.type == RSS::OPDS::TYPES['navigation']
            raise TypeError, 'Only navigatfion feed can accept feed' unless is_navigation_feed
            raise ArgumentError, 'Only acquisition feed can be accepted' unless feed.acquisition_feed?
            new_item do |entry|
              [:id, :title, :dc_description, :updated].each do |attr|
                val = feed.__send__(attr)
                entry.__send__("#{attr}=", val.content) if val
              end
              entry.links.new_link do |link|
                href = feed.links.find {|ln| ln.rel == RSS::OPDS::RELATIONS['self']}.href unless href
                link.href = href
                link.rel = relation
                link.type = RSS::OPDS::TYPES['acquisition']
              end

              entry
            end
          end

          ::RSS::OPDS::CATALOG_RELATIONS.each_pair do |type, uri|
            define_method "add_#{type}" do |feed, href=nil|
              add_relation feed, uri, href
            end
          end
        end
      end
    end
  end
end
