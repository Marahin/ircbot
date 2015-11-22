#encoding: utf-8
require 'cinch'
require 'feedjira'

module MultithreadedEach
  def multithreaded_each
    each_with_object([]) do |item, threads|
      threads << Thread.new { yield item }
    end.each { |thread| thread.join }
    self
  end
end


#Feedjira::Feed.fetch_and_parse("http://feeds.feedburner.com/niebezpiecznik/" )
#Feedjira::Feed.fetch_and_parse("http://zaufanatrzeciastrona.pl/feed/" )

$feeds = [
    {
        :name => 'z3s.pl',
        :link => 'http://zaufanatrzeciastrona.pl/feed/',
        :last_entry_id => Time.now
    },
    {
        :name => 'niebezpiecznik',
        :link => 'http://feeds.feedburner.com/niebezpiecznik/',
        :last_entry_id => Time.now
    },
    {
        :name => 'marahin.pl',
        :link => 'http://marahin.pl/?feed=rss2',
        :last_entry_id => Time.now
    }
].extend(MultithreadedEach)

class Rss
  include Cinch::Plugin

  match /rss force/, method: :force_refresh_feed
  match /rss next/, method: :print_last_entry

  def refresh_feed
    @news = []
    $feeds.multithreaded_each do |feed|
      puts "Feed for #{ feed[:name] } started."
      new_news = []
      val = Feedjira::Feed.fetch_and_parse(feed[:link])
      val.entries.reverse!.each do |entry|
        if entry.entry_id == feed[:last_entry_id]
          break;
        else
          new_news.push({
                            :source => feed[:name],
                            :title => entry.title,
                            :author => entry.author,
                            :url => (Object.const_defined?('Gimbus') ? (Gimbus.shorten(entry.url)) : (entry.url)),
                            :content => remove_html_tags(entry.summary.to_s || entry.content.to_s).slice!(0, 17) + '...'
                        })
        end
      end
      feed[:last_entry_id] = val.entries.reverse!.first.entry_id
      @news += new_news
      puts "Feed for #{ feed[:name] } finished."
    end
  end

  def force_refresh_feed(m)
    m.reply "Refreshing feed just for you, #{ m.user.nick }."
    refresh_feed
  end

  def print_last_entry(m)
    if @news
      last_entry = @news.last
      puts "last_entry: #{last_entry.to_s}"
      puts "last_entry: #{last_entry}"
      m.reply("[#{ last_entry[:source] }] #{ last_entry[:title] } - #{last_entry[:author]}: #{ last_entry[:content]} { #{ last_entry[:url]} }")
    else
      m.reply( "There are no news at this moment.")
    end
    @news.pop()

    @news.shuffle!
  end

  private

  def remove_html_tags(text)
    re = /<("[^"]*"|'[^']*'|[^'">])*>/
    text.gsub!(re, '')
    text
  end

end
