# This is an example that aggregates info from EPUB files and build OPDS catalog feed using them
# 
# Usage:
#   ruby examples/build-catalog-from-epub.rb EPUBFILE
#   ruby examples/build-catalog-from-epub.rb ~/Documents/Books/*.epub

require 'rss'
require 'rss/opds'
require 'rss/maker/opds'
require 'epub/parser' # You need to exec 'gem install epub-parser' if you don't have it

def main
  if ARGV.empty?
    puts "Usage: ruby #{File.basename($0)} EPUBFILE [EPUBFILE ...]"
    exit 1
  end

  puts make_catalog(ARGV)
end

def make_catalog(files)
  RSS::Maker.make 'atom' do |maker|
    maker.channel.about = 'http://example.net/'
    maker.channel.title = 'My EPUB books'
    maker.channel.description = 'This is an example to make OPDS catalog using RSS::OPDS library'
    maker.channel.links.new_link do |link|
      link.href = 'http://example.net/'
      link.rel = RSS::OPDS::RELATIONS['self']
      link.type = RSS::OPDS::TYPES['navigation']
    end
    maker.channel.links.new_link do |link|
      link.href = 'http://example.net/'
      link.rel = RSS::OPDS::RELATIONS['start']
      link.type = RSS::OPDS::TYPES['navigation']
    end
    maker.channel.author = `whoami`.chomp
    maker.channel.generator = 'RSS OPDS the Ruby OPDS library'
    maker.channel.updated = Time.now

    files.sort.each do |file|
      begin
        make_entry(file, maker)
      rescue => error
        $stderr.puts error
        $stderr.puts "skip: #{file}"
      end
    end
  end
end

def make_entry(file, maker)
  book = EPUB::Parser.parse(file)
  maker.items.new_item do |entry|
    entry.id = book.metadata.unique_identifier.content
    entry.title = book.title
    entry.updated = Time.parse(book.metadata.dates.first.content)
    entry.summary = book.metadata.descriptions.join(' ')
  end
end

main
