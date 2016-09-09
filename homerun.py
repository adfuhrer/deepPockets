#!python3
import tensorflow as tf
import numpy as np

#Data Sets
TRAINING_FILE = "training_full2014.csv"
TEST_FILE = "test_full2014.csv"

# Load Datasets
training_set = tf.contrib.learn.datasets.base.load_csv(filename=TRAINING_FILE, target_dtype=np.int)
test_set = tf.contrib.learn.datasets.base.load_csv(filename=TEST_FILE, target_dtype=np.int)

x_train, x_test, y_train, y_test = training_set.data, test_set.data, training_set.target, test_set.target

# second try
classifier = tf.contrib.learn.DNNClassifier(hidden_units=[256], n_classes=2)
# our first approach
#classifier = tf.contrib.learn.DNNClassifier(hidden_units=[30, 50, 10], n_classes=2)
print('training finished')

# Fit model.
classifier.fit(x=x_train, y=y_train, steps=200)

# Evaluate accuracy.
evaluation = classifier.evaluate(x=x_test, y=y_test)
accuracy_score = evaluation["accuracy"]
print(evaluation)
print('Accuracy: {0:f}'.format(accuracy_score))

