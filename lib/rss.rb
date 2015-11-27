#encoding: utf-8
require 'feedjira'

class Rss
  include Cinch::Plugin

  # module for running .each with every block being ran in a parallel thread

  module MultithreadedEach
    def multithreaded_each
      each_with_object([]) do |item, threads|
        threads << Thread.new { yield item }
      end.each { |thread| thread.join }
      self
    end
  end

  #feeds
  $feeds = [
      {
          :name => 'z3s.pl',
          :link => 'http://zaufanatrzeciastrona.pl/feed/',
          :last_entry_id => nil
      },
      {
          :name => 'niebezpiecznik',
          :link => 'http://feeds.feedburner.com/niebezpiecznik/',
          :last_entry_id => nil
      },
      {
          :name => 'marahin.pl',
          :link => 'http://marahin.pl/?feed=rss2',
          :last_entry_id => nil
      }
  ].extend(MultithreadedEach)
  #end of feeds

  match /rss force/, method: :force_refresh_feed
  match /rss next/, method: :print_last_entry
  match /rss start/, method: :start_announcing
  match /rss stop/, method: :stop_announcing
  match /rss raport/, method: :raport

  timer (60+(300/(@@news.length+1))), method: :announce_news_to_channel, threaded: true
  timer 300, method: :refresh_feed, threaded: true

  # we want to disable announcing by default, so it is being started by a user
  @@announce = false
  @@news = []
  @@last_time_updated = Time.now

  def start_announcing(m)
    @@announce = true
    m.reply 'I will announce news from now on.'
  end
  
  
  def raport(m)
    m.reply "feeds: #{ $feeds.length }, queue: #{ @@news.length } news awaiting. Last time updated: #{ @@last_time_updated }"
  end
  
  def stop_announcing(m)
    @@announce = false
    m.reply 'I will not announce news for now.'
  end

  def force_refresh_feed(m)
    m.reply "Refreshing feed just for you, #{ m.user.nick }."
    refresh_feed
  end

  def print_last_entry(m)
    if not @@news.empty?
      last_entry = @@news.last
      m.reply("[#{ last_entry[:source] }] #{ last_entry[:title] } - #{last_entry[:author]}: #{ last_entry[:content]} { #{ last_entry[:url]} }")
      @@news.pop()
      @@news.shuffle!
    else
      m.reply('There are no news at this moment.')
    end
  end

  private

  def refresh_feed
    $feeds.multithreaded_each do |feed|
      new_news = []
      val = Feedjira::Feed.fetch_and_parse(feed[:link])
      val.entries.each do |entry|
        if entry.url == feed[:last_entry_id]
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
      feed[:last_entry_id] = val.entries.first.url
      @@news += new_news
      @@last_time_updated = Time.now
    end
  end

  def announce_news_to_channel()
    if @@announce
      if @@news
        last_entry = @@news.last
        #m.reply("[#{ last_entry[:source] }] #{ last_entry[:title] } - #{last_entry[:author]}: #{ last_entry[:content]} { #{ last_entry[:url]} }")
        #Message.reply("[#{ last_entry[:source] }] #{ last_entry[:title] } - #{last_entry[:author]}: #{ last_entry[:content]} { #{ last_entry[:url]} }")
        Channel('#3lab-news').send("[#{ last_entry[:source] }] #{ last_entry[:title] } - #{last_entry[:author]}: #{ last_entry[:content]} { #{ last_entry[:url]} }")
        @@news.pop
        @@news.shuffle!
      end
    end
  end

  def remove_html_tags(text)
    re = /<("[^"]*"|'[^']*'|[^'">])*>/
    text.gsub!(re, '')
    text
  end

  def is_an_admin?( user )
    if $admins.nil?
      true
    else
      $admins.include?( user.authname ) ? ( true ) : ( false )
    end
  end

end
