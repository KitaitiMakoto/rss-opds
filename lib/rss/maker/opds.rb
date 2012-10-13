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
                def_classed_elements 'price', 'value'

                class Prices < Base
                  def_array_element 'price'
                  add_other_element 'price'

                  class Price < Base
                    attr_accessor :value, :currencycode
                    add_need_initialize_variable :value, :currencycode

                    def to_feed(feed, current)
                      price = current.class::Link::Price.new
                      setup_values price


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
