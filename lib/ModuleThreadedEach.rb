#module for threaded .each method

module MultithreadedEach
  def multithreaded_each
    each_with_object([]) do |item, threads|
      threads << Thread.new { yield item }
    end.each { |thread| thread.join }
    self
  end
end