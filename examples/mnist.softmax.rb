require 'pybind'
require 'pybind/autocall'
include PyBind::Import

pyfrom 'tensorflow.examples.tutorials.mnist', import: :input_data
pyimport 'tensorflow', as: :tf

DATA_DIR = '/tmp/tensorflow/mnist/input_data'

# Import data
mnist = input_data.read_data_sets(DATA_DIR, one_hot: true)

# Create the model
x = tf.placeholder(tf.float32, [nil, 784])
W = tf.Variable(tf.zeros([784, 10]))
b = tf.Variable(tf.zeros([10]))
y = tf.matmul(x, W) + b

# Define loss and optimizer
y_ = tf.placeholder(tf.float32, [nil, 10])

# The raw formulation of cross-entropy,
#
#   tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(tf.nn.softmax(y)),
#                                 reduction_indices: [1]))
#
# can be numerically unstable.
#
# So here we use tf.nn.softmax_cross_entropy_with_logits on the raw
# outputs of 'y', and then average across the batch.
cross_entropy = tf.reduce_mean(
    tf.nn.softmax_cross_entropy_with_logits(labels: y_, logits: y))
train_step = tf.train.GradientDescentOptimizer(0.5).minimize(cross_entropy)

sess = tf.InteractiveSession()
tf.global_variables_initializer().run()

# Train
1000.times do
  batch_xs, batch_ys = mnist.train.next_batch(100)
  sess.run(train_step, feed_dict: {
    x => batch_xs, # but what I want is just x => batch_xs,
    y_ => batch_ys
    })
end

# Test trained model
correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
puts(sess.run(accuracy, feed_dict: {
  x => mnist.test.images,
  y_ => mnist.test.labels
  }))
