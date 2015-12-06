
import SVMClassifier.SVMClassifier as svm
import GMeans.gmeans as gm
from sklearn.preprocessing import normalize
import os

class HeartBeatClassifier(object):
    def __init__(self):
        self.svm_classifier = svm.SVMClassifier()
        self.g_means = gm.GMeans()

    def classify(self):
        number_of_clusters = 2;
        data = __getQrsComplexDataFromFile('ConvertedQRSRawData.txt')
        normalizedQrsComplexData = __convertToQrsComplexData__(data)
        gmeans = g_means.ClusterData(normalizedQrsComplexData)
        svm_classifier.predict(gmeans)
        
    def __convertToQrsComplexData__(self, data):
        normalizedData = dict((k, normalize(v[:,np.newaxis], axis= 0).ravel()) for (k,v) in data.items())
        #return 
        
    def __getQrsComplexDataFromFile(self, path):
        dir = os.path.dirname(__file__)
        filename = os.path.join(dir, path)
        print filename
        with open(filename, "r") as ins:
            return [QRSData(line.split()) for line in ins]


