from SVMClassifier.src.HeartBeatClassifier.QRSData import QRS_DATA
import logging

class GMeans(object):
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def clusterData(self, qrs_complexes, max_k):
        self.logger.debug('In clusterData')

    def qrsToGslVectors(self):
        pass

def main():
    # gmeans_logger = logging.getLogger(__name__)
    pass


if __name__ == '__main__':
    main()
