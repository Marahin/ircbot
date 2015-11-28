#encoding: utf-8
require 'feedjira'
require 'json'

class Rss
  include Cinch::Plugin
  
  set :help, <<-EOF
rss start
  (ADMIN) tells cinch to start
  announcing news feeds.
rss stop
  (ADMIN) tells cinch to stop 
  announcing news feeds.
rss force
  (ADMIN) tells cinch to force-
  refresh the newsfeeds.
rss next
  tells cinch to drop some cool
  news.
rss report
  tells cinch to drop some stats
EOF

  $feeds = [
      {
          :name => 'z3s.pl',
          :link => 'http://zaufanatrzeciastrona.pl/feed/',
          :last_entry_id => $db.use('feeds').get('z3s.pl#last_url')
      },
      {
          :name => 'niebezpiecznik.pl',
          :link => 'http://feeds.feedburner.com/niebezpiecznik/',
          :last_entry_id => $db.use('feeds').get('niebezpiecznik.pl#last_url')
      },
      {
          :name => 'hackerNews',
          :link => 'http://hnrss.org/newest',
          :last_entry_id => $db.use('feeds').get('hackerNews#last_url')
      },
      {
          :name => 'marahin.pl',
          :link => 'http://marahin.pl/?feed=rss2',
          :last_entry_id => $db.use('feeds').get('marahin.pl#last_url')
      }
  ].extend(MultithreadedEach)
  #end of feeds


  ## VARIABLES ##
  # we want to disable announcing by default, so it is being started by a user
  @@announce = false
  # initializng news stack
  @@news = Array.new
  # last_time feed was updated (set by refresh_feed)
  @@last_time_updated = Time.now

  ## ROUTES ##
  match /rss force/, method: :force_refresh_feed
  match /rss next/, method: :print_last_entry
  match /rss start/, method: :start_announcing
  match /rss stop/, method: :stop_announcing
  match /rss report/, method: :raport

  ## TIMERS (recursive functions delayed by time)
  timer (60+(300/(@@news.length+1))), method: :announce_news_to_channel, threaded: true
  timer 300, method: :refresh_feed, threaded: true

  ## METHODS ##
  
  def start_announcing(m)
    return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( false ))
    @@announce = true
    m.reply 'I will announce news from now on.'
  end
  
  def raport(m)
    fetch_news_stack_from_db
    m.reply "#{ $RESULT_CHARACTER } feeds: #{ $feeds.length }, queue: #{ @@news.count } news awaiting. Last time updated: #{ @@last_time_updated }"
  end
  
  def stop_announcing(m)    
    return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( false ))
    @@announce = false
    m.reply "#{ $RESULT_CHARACTER } I will not announce news for now."
  end

  def force_refresh_feed(m)    
    return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( false ))
    m.reply "#{ $RESULT_CHARACTER } Refreshing feed just for you, #{ m.user.nick }."
    refresh_feed
  end

  def print_last_entry(m)
    fetch_news_stack_from_db
    if not @@news.empty?
      last_entry = hash_string_indexes_to_symbols( @@news.last )
      puts "last_entry: #{ last_entry }"
      m.reply("#{ $RESULT_CHARACTER } [#{ last_entry[:source] }] #{ last_entry[:title] } - #{last_entry[:author]}: #{ last_entry[:content]} { #{ last_entry[:url]} }")
      @@news.pop()
      @@news.shuffle!
      $db.use('feeds').set('news', @@news.to_json)
    else
      m.reply "#{ $RESULT_CHARACTER } There are no news at this moment."
    end
  end

  private

  def refresh_feed
    fetch_news_stack_from_db
    $feeds.multithreaded_each do |feed|
      feed[:last_entry_id] = $db.use('feeds').get("#{feed[:name]}#last_url")
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
      $db.use('feeds').set("#{ feed[:name] }#last_url", feed[:last_entry_id])
      @@news += new_news
      $db.use('feeds').set('news', @@news.to_json)
      @@last_time_updated = Time.now
    end
  end

  def announce_news_to_channel()
    if @@announce
      fetch_news_stack_from_db
      if @@news
        last_entry = hash_string_indexes_to_symbols( @@news.last )
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

  def hash_string_indexes_to_symbols(hash)
    hash.keys.each do |key|
      hash[(key.to_sym rescue key) || key] = hash.delete(key)
    end

    hash
  end

  def fetch_news_stack_from_db
    @@news = $db.use('feeds').get('news')
    if @@news.class == String
      if @@news != '[]'
        @@news = JSON.parse( @@news )
      else
        @@news = []
      end
    else
      @@news = []
    end    
  end
end
