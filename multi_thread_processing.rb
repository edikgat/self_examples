require 'thread'
class MultiThreadProcessing
  
  class Error < StandardError
  end

  def initialize(max_thread_number = 5)
    @max_thread_number = max_thread_number
  end

  def process(collection, &mapper)
    @collection = collection
    @mapper = mapper
    make_processing
  end

  private

  def make_processing
    init_private_settings
    process_items
    process_queue
    rescue StandardError => m
      @thread_group.enclose
      raise Error, m
  end

  def process_items
    @thread_group.add(
      Thread.new do
        process_collection
      end
    )
  end

  def process_collection
    @collection.each do |item|
      @thread_group_mutex.synchronize do
        add_thread(item)
        @resource.wait(@thread_group_mutex)
      end
    end
  end

  def init_private_settings
    Thread.abort_on_exception = true
    @thread_group_mutex = Mutex.new
    @resource = ConditionVariable.new
    @thread_group = ThreadGroup.new
    @queue = Queue.new
  end

  def add_thread(item)
    Thread.new do
      new_thread_event_if_it_needed            
      process_item(item)
      new_thread_event
    end
  end

  def new_thread_event
    @thread_group_mutex.synchronize do
      @resource.signal
    end
  end

  def new_thread_event_if_it_needed
    @thread_group_mutex.synchronize do
      if @thread_group.list.length < @max_thread_number
        @resource.signal
      end
    end
  end

  def process_item(item)
    processed_item = @mapper.call(item)
    @queue << processed_item
  end

  def process_queue
    arr = []
    @collection.size.times do
      arr << @queue.pop
    end
    arr
  end

end
