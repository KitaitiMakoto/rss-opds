# Usage
#   $ DOCUMENT_ROOT=path/to/doc/root rackup examples/opds_server.ru
#
# If required gems are not installed, you need exec:
#   $ gem install rack epub-parser
require 'pathname'
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
    @dir, @options = Pathname(dir), OPTIONS.merge(options)
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
            uri_path = Pathname(path).relative_path_from(@dir)
            entry.links.new_link do |link|
              link.rel  = RSS::OPDS::RELATIONS['acquisition']
              link.href = @request.base_url + '/' + ERB::Util.url_encode(uri_path.to_path)
              link.type = 'application/epub+zip'
            end
            updated = Time.parse(book.date.content) rescue nil
            entry.updated = updated || File.mtime(path)
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

run OPDSServer.new(ENV['DOCUMENT_ROOT'])
