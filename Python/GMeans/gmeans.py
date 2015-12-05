# from SVMClassifier.HeartBeatClassifier.QRSData import QRS_DATA
from anderson_darling_test import AndersonDarlingTest
from scipy.cluster.vq import kmeans2
import logging


class GMeans(object):
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def cluster_data(self, qrs_complexes, max_k):
        self.logger.debug('In clusterData')
        data = self.qrs_to_gsl_vectors(qrs_complexes)
        qrs_centroids = kmeans2(data, max_k, iter=100)
        # :TODO: Check how kmeans2 beahaves and what input data it requires.
        return qrs_centroids

    def anderson_darling_test(self, data, alpha):
        # To tylko wywolanie metody z zewnetrznego modulu.
        self.logger.debug("In anderson_darling_test")
        AndersonDarlingTest(data, alpha)

    def qrs_to_gsl_vectors(self, qrs_complexes):
        # Ta metoda w tym momencie nie ma zadnego sensu
        # :TODO: This method might be used to prepare data for the kmeans implementation that we'll use.
        self.logger.debug('In qrsToGslVectors')
        return []


def main():
    pass


if __name__ == '__main__':
    main()
