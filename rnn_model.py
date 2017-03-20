import tensorflow as tf
import numpy as np


lstm = tf.contrib.rnn.BasicLSTMCell(50, forget_bias=0.0, state_is_tuple=True, reuse=tf.get_variable_scope().reuse)
#define length of time data
max_length = 2617572
data = tf.placeholder(tf.float32, [None, max_length, 38])
output, _ = tf.nn.dynamic_rnn(lstm, data, dtype=tf.float32)



