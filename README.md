self_examples
=============

## MultiThreadProcessing class
###Initialize

    MultiThreadProcessing.new(max_thread_number)

###Methods

    MultiThreadProcessing.new(max_thread_number).process(collection, &block_of_code)

###Methods examples

    MultiThreadProcessing.new(5).process(10.times, &Proc.new{ |x| x*x*x})

will return

    => [0, 1, 4, 16, 9, 25, 36, 49, 64, 81]
