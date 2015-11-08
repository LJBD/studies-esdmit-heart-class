
from SVMClassifier import *

class HeartBeatClassifier(object):
    def __init__(self):
        self.svm_classifier = SVMClassifier()
        # self g_means = GMeans()

    def classify(self, data):
        number_of_clusters = data["k"]


