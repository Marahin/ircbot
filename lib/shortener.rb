#encoding: utf-8
require 'open-uri'
require 'cinch'

class Gimbus
  include Cinch::Plugin

  listen_to :channel

  def self.shorten(url)
    url = open("http://gimb.us/?url=#{URI.escape(url)}").read()
    if url
      return "http://gimb.us/#{url[1..url.length]}"
    end
  rescue OpenURI::HTTPError
    nil
  end

  def listen(m)
    urls = URI.extract(m.message, "http")
    short_urls = urls.map { |url| Gimbus.shorten(url) }.compact
    unless short_urls.empty?
      m.reply "➥ #{short_urls.join(", ")}"
    end
  end
end