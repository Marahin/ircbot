#module for threaded .each method

module MultithreadedEach
  def multithreaded_each
    each_with_object([]) do |item, threads|
      threads << Thread.new { yield item }
    end.each { |thread| thread.join }
    self
  end
  # below is a prettier version of the above.
  # however in the tests i've introduced
  # the below version results in worse
  # performance than the upper one,
  # so for now I leave the upper as the main one
  # and the other one "to be checked out sooner or later"
  # maybe in other cases
  def map_mt_each
    map { |e| Thread.new { yield e } }.each(&:join)
  end
end
