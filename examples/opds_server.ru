# Replace directory name at bottom of this file with your directory which has EPUB books
# 
# Usage
#   rackup examples/opds_server.ru
#
# If required gems are not installed, you need exec:
#   gem install rack epub-parser
require 'rack'
require 'epub/parser'
require 'rss/maker/opds'

class OPDSServer
  OPTIONS = {
    :title       => 'My EPUB Books',
    :description => 'This is an example server that serve OPDS includes info of EPUB files in a directory.',
    :author      => `whoami`.chomp,
    :generator   => self.to_s
  }

  def initialize(dir='.', options={})
    raise "Not a directory: #{dir}" unless File.directory? dir
    @dir, @options = dir, OPTIONS.merge(options)
    $stderr.puts "Provides OPDS for EPUB files in #{@dir}"
  end

  def call(env)
    @files = Dir["#{@dir}/**/*.epub"]

    @request = Rack::Request.new(env)
    response = Rack::Response.new

    if env['HTTP_IF_MODIFIED_SINCE'] and
        last_modified.to_s <= Time.httpdate(env['HTTP_IF_MODIFIED_SINCE']).to_s
      response.status = Rack::Utils.status_code(:not_modified)
    elsif !@request.head?
      response.body << make_feed.to_s
    end

    response['Content-Type'] = RSS::OPDS::TYPES['navigation']
    response['Last-Modified'] = last_modified.httpdate
    response.finish
  end

  def make_feed
    RSS::Maker.make('atom') {|maker|
      maker.channel.about = @options[:about] || @request.url
      OPTIONS.keys.each do |attr|
        maker.channel.send "#{attr}=", @options[attr]
      end
      maker.channel.updated = last_modified
      @files.each do |path|
        begin
          book = EPUB::Parser.parse(path)
          maker.items.new_item do |entry|
            entry.id = book.unique_identifier.content
            entry.title = book.title
            entry.summary = book.description
            updated = book.date
            entry.updated = updated ? updated.content : File.mtime(path)
          end
        rescue => error
          $stderr.puts error
          $stderr.puts "Skip: #{path}"
        end
      end
    }
  end

  def last_modified
    @last_modified ||= @files.collect {|epub| File.mtime epub}.max
  end
end

# Replace argument with directory which has EPUB files
run OPDSServer.new("#{Dir.home}/Documents/Books")
