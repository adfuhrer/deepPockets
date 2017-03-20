#!python3
import tensorflow as tf
import numpy as np
from operator import itemgetter
#Data Sets
TRAINING_FILE = "training_new15_3.csv"
TEST_FILE = "test_new15_3.csv"
import itertools



# Load Datasets
training_set = tf.contrib.learn.datasets.base.load_csv_with_header(filename=TRAINING_FILE,target_dtype=np.int,features_dtype=np.float32)
test_set = tf.contrib.learn.datasets.base.load_csv_with_header(filename=TEST_FILE, target_dtype=np.int,features_dtype=np.float32)

x_train, x_test, y_train, y_test = training_set.data, test_set.data, training_set.target, test_set.target
feature_columns = [tf.contrib.layers.real_valued_column("", dimension=38)]

classifier = tf.contrib.learn.DNNClassifier(feature_columns=feature_columns,hidden_units=[50],n_classes=2)


# Fit model.
classifier.fit(x=x_train, y=y_train ,steps=10)
# Evaluate accuracy.
evaluation = classifier.evaluate(x=x_test, y=y_test)
accuracy_score = evaluation["'precision/positive_threshold_0.500000_mean'"]

print('Accuracy: {0:f}'.format(accuracy_score))
predictions = list((classifier.predict(x_test,as_iterable=True)))
print(predictions)


