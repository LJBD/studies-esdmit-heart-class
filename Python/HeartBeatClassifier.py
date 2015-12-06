import SVMClassifier.SVMClassifier as svm
from SVMClassifier.QRSData import QRSData
import GMeans.gmeans as gm
from sklearn.preprocessing import normalize
import os
import sys
reload(sys)
sys.setdefaultencoding("utf-8")


class HeartBeatClassifier(object):
    def __init__(self):
        self.svm_classifier = svm.SVMClassifier()
        self.g_means = gm.GMeans()

    def classify(self):
        number_of_clusters = 2
        data = self.getQrsComplexDataFromFile('ConvertedQRSRawData.txt')
        normalizedQrsComplexData = self.convertToQrsComplexData(data)
        gmeans = self.g_means.cluster_data(normalizedQrsComplexData)
        self.svm_classifier.predict(gmeans)
        
    def convertToQrsComplexData(self, data):
        normalized_data = dict((k, normalize(v[:,np.newaxis], axis= 0).ravel()) for (k,v) in data.items())
        return normalized_data
        
    def getQrsComplexDataFromFile(self, path):
        dir = os.path.dirname(os.path.dirname(__file__))
        dir = os.path.join(dir, 'Sygnały z C++')
        filename = os.path.join(dir, path)
        print filename
        with open(filename, "r") as ins:
            return [QRSData(line.split()) for line in ins]

    def run(self):
        pass


def main():
    hbc = HeartBeatClassifier()
    hbc.classify()
    #hbc.run()

if __name__ == '__main__':
    main()
