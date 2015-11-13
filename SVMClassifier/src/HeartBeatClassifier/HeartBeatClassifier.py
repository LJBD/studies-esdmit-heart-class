from SVMClassifier import *
from sklearn.preprocessing import normalize


class HeartBeatClassifier(object):
    def __init__(self):
        self.svm_classifier = SVMClassifier()
        # self g_means = GMeans()

    def classify(self, data):
        number_of_clusters = data["k"]
        normalizedQrsComplexData = __convertToQRSComplexData__(data)
 #       gmeans = g_meand.ClusterData(normalizedQrsComplexData)
        svm_classifier.predict(gmeans)


    def __convertToQRSComplexData__(self,data):
        normalizedData = dict((k, normalize(v[:,np.newaxis], axis=0).ravel()) for (k,v) in data.items())
        return [QrsComplexData(simpleData["gd"]) for simpleData in normalizedData] #implement others



