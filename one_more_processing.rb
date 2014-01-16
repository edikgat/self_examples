require 'thread'
class OneMoreProcessing
  
  class Error < StandardError
  end

  def initialize(max_thread_number = 5)
    @max_thread_number = max_thread_number
  end

  def process(collection, &mapper)
    @collection = make_array(collection)
    @mapper = mapper
    make_processing
  end

  private

  def make_array(collection)
    return collection if collection.is_a? Array
    collection.map do |item|
      item
    end
  end

  def make_processing
    init_private_settings
    process_items
    process_output_queue
    rescue StandardError => m
      @thread_group.enclose
      raise Error, m
  end

  def init_private_settings
    Thread.abort_on_exception = true
    @thread_group = ThreadGroup.new
    @output_queue = Queue.new
    calculate_thread_number
  end

  def process_items
    @thread_group.add(Thread.new do
      processed_items_count = 0
      processed_items_count_mutex = Mutex.new
      @thread_number.times do
        @thread_group.add(
          Thread.new do
            catch :close_thread do
              loop do |item|
                processed_items_count_mutex.synchronize do
                  if processed_items_count < @collection.size
                    item = @collection[processed_items_count]
                    processed_items_count += 1
                  else
                     throw :close_thread
                  end
                end
                process_item(item)
              end
            end
          end
        )
      end
    end)
  end

  def calculate_thread_number
    if @collection.size > @max_thread_number
      @thread_number = @max_thread_number
    else
      @thread_number = @collection.size
    end
  end

  def process_item(item)
    processed_item = @mapper.call(item)
    @output_queue << processed_item
  end

  def process_output_queue
    arr = []
    @collection.size.times do
      arr << @output_queue.pop
    end
    arr
  end

end
