require 'rss/opds'
require 'test/unit'
require 'pathname'

class TestOPDS < Test::Unit::TestCase
  def setup
    @fixtures_dir = Pathname(__FILE__).dirname.expand_path + 'fixtures'
  end
end

Book = Struct.new 'Book',
                  :title, :author, :summary, :updated, :link, :popularity

