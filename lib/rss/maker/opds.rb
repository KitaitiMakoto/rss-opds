require 'rss/maker'
require 'rss/opds'

module RSS
  module Maker
    module Atom
      class Feed < RSSBase
        class Items < ItemsBase
          class Item < ItemBase
            class Links < LinksBase
              class Link < LinkBase
                %w[facetGroup activeFacet].each do |attr|
                  # attr_accessor attr, Utils.to_attr_name(attr)
                  # add_need_initialize_variable attr
                  def_other_element attr
                end
                def_classed_elements 'opds_price', 'value', 'Prices'
                def setup_opds_prices(feed, current)
                  # noop
                end

                # Should provide this method as the one of a module
                def to_feed(feed, current)
                  super # AtomLink#to_feed
                  opds_prices.to_feed(feed, current.links.last)
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
          end

          def add_root_link(href)
            raise NotImplementedError
          end

          # @todo consider whether method name is proper or not
          def add_feed(feed, relation, href=nil)
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
            end
          end
        end
      end
    end
  end
end
