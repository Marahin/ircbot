#encoding: utf-8
require 'open-uri'
require 'mechanize'

class Gimbus
  include Cinch::Plugin

  listen_to :channel

  Help.add_plugin(self.name, __FILE__, "Gimb.us Shortener implementation. Shortens every link sent on every channel.")
  
  def self.shorten(url)
    unless url.include?( "http://gimb.us/" )
      url = open("http://gimb.us/?url=#{URI.escape(url)}").read()
      if url
        return "http://gimb.us/#{url[1..url.length]}"
      end
    else
      return url
    end
    rescue OpenURI::HTTPError
      nil
  end

  def listen(m)
    urls = URI.extract(m.message, ["http", "https", "www."] )
    short_urls = urls.map { |url| Gimbus.shorten(url) + " - " + get_page_title( url ).gsub(/\n/, " ").gsub(/\r/, " ").slice(0..97) + "..." }.compact
    unless short_urls.empty?
      m.reply "#{ $RESULT_CHARACTER } #{short_urls.join(", ")}"
    end
  end

  private

  def get_page_title( page_address )
    page_obj = Mechanize.new.get( page_address )
    if page_obj.respond_to?(:title)
      # return title (if we can access it)
      page_obj.title
    else
      # return filename if there's no page title
      if page_obj.respond_to?(:filename)
        page_obj.filename
      else
        # if we can't access anything - return homepage title
        get_page_title( "http://" + page_obj.uri.host + "/" )
      end
    end
  end
end
