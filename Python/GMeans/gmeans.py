from anderson_darling_test import AndersonDarlingTest
from scipy.cluster.vq import kmeans2
import numpy
import logging
from matplotlib import pyplot


class GMeans(object):
    def __init__(self, log_level='INFO'):
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(log_level)
        ch = logging.StreamHandler()
        ch.setLevel(log_level)
        self.logger.addHandler(ch)
        self.labels_dict = {}
        self.qrs_data = None
        self.centroids = None
        self.k = 0
        # self.dummy_data = QRSData()

    def cluster_data(self, qrs_complexes, max_k=50):
        self.logger.debug('In clusterData')
        self.qrs_data = self.qrs_conversion(qrs_complexes)

        ########################################
        # Start the algorithm
        ########################################
        initial_centroid = self.calculate_mean(self.qrs_data)
        print('INITIAL CENTROID: ', initial_centroid)
        self.centroids = numpy.array([initial_centroid])
        self.k = len(self.centroids)

        while self.k < max_k:
            # this flag will inform us if anything was added to the centroids
            added_to_centroids_flag = False
            self.centroids, labels_for_data = kmeans2(self.qrs_data, k=numpy.array(self.centroids),
                                                      minit='matrix', iter=100)
            # :TODO: Check how kmeans2 beahaves and what input data it requires.
            self.logger.debug('k-means resulted in centroids: %s' % self.centroids)
            self.set_proper_labels(labels_for_data)

            for centroid_index, centroid in enumerate(self.centroids):
                data_for_centroid = self.get_data_dict_for_centroid(centroid_index)
                test_outcome, new_centroids, new_labels_for_data = self.run_test(centroid, data_for_centroid)
                if test_outcome:
                    pass
                else:
                    added_to_centroids_flag = True
                    # :TODO: Add else, in which I will update the labels_for_centroid with the two new centros' indices!
                    self.update_after_centroid_addition(centroid_index, data_for_centroid, new_centroids,
                                                        new_labels_for_data)

            if added_to_centroids_flag is False:
                self.logger.info('I\'ve added nothing, so I\' stopping the algorithm. K = %d' % self.k)
                break
            else:
                pass
        # :TODO: Finish this method!

        return self.centroids

    def update_after_centroid_addition(self, centroid_index, data_for_centroid, new_centroids, new_labels_for_data):
        # the first centroid gets the old index
        self.centroids[centroid_index] = new_centroids[0]
        # the second is appended at the end
        self.centroids = numpy.concatenate(self.centroids, new_centroids[1])
        new_centroid_index = len(self.centroids) - 1
        for i, label in enumerate(new_labels_for_data):
            if label == 2:
                data_index_to_be_updated = list(data_for_centroid.keys())[i]
                self.labels_dict[data_index_to_be_updated] = new_centroid_index
            else:
                data_index_to_be_kept = list(data_for_centroid.keys())[i]
                if self.labels_dict[data_index_to_be_kept] != centroid_index:
                    raise ValueError('Mismatching index of the centroid for %d!' % data_index_to_be_kept)

    def set_proper_labels(self, labels_for_data):
        for i, centroid_number in enumerate(labels_for_data):
            self.labels_dict[i] = centroid_number

    def anderson_darling_test(self, data, alpha=0.0001):
        self.logger.debug("In anderson_darling_test")
        return AndersonDarlingTest(data, alpha)

    def run_test(self, centroid, data_for_centroid):
        self.logger.debug("In run_test")
        data_list = self.get_data_list_for_centroid(data_for_centroid)
        child_centroids = self.get_child_centroids(centroid, data_list)
        new_centroids, labels_for_data = kmeans2(data_list, k=child_centroids, iter=100, minit='matrix')
        if len(new_centroids) == 2:
            v = [new_centroids[0][i] - new_centroids[1][i] for i in range(len(new_centroids[0]))]
            projected_data = self.project_data_on_v(data_list, v)
            test_outcome = self.anderson_darling_test(projected_data)
            return test_outcome, new_centroids, labels_for_data
        else:
            raise ValueError('Unexpected number of centroids (not 2).')

    def project_data_on_v(self, data_list, v):
        self.logger.debug('In project_data_on_v')
        projected_data = []
        norm_of_v = numpy.linalg.norm(v)
        for data_vector in data_list:
            dot_product = numpy.dot(v, data_vector)
            projected_data.append(dot_product/norm_of_v)
        return projected_data

    def get_child_centroids(self, centroid, data_list):
        self.logger.debug("In get_child_centroids")
        mean = self.calculate_mean(data_list)
        child_centroid_1 = [centroid[i] - mean[i]/100.0 for i in range(len(centroid))]
        child_centroid_2 = [centroid[i] + mean[i]/100.0 for i in range(len(centroid))]
        return numpy.array([child_centroid_1, child_centroid_2])

    def get_real_data_from_indices(self, dict_of_indices):
        self.logger.debug("In get_real_data_from_indices")
        return numpy.array([self.qrs_data[i] for i in dict_of_indices.keys()])

    def qrs_conversion(self, qrs_complexes):
        # Convert a list of data to a numpy array of one.
        self.logger.debug('In qrs_conversion')
        if isinstance(qrs_complexes, numpy.ndarray):
            return qrs_complexes
        else:
            return numpy.array(qrs_complexes)

    def get_data_dict_for_centroid(self, centroid_index):
        self.logger.debug("In get_data_for_centroid")
        data_for_centroid = {}
        for data_index in self.labels_dict.keys():
            if self.labels_dict[data_index] == centroid_index:
                data_for_centroid[data_index] = self.qrs_data[data_index]
        return data_for_centroid

    @staticmethod
    def get_data_list_for_centroid(data_for_centroid):
        number_of_keys = len(data_for_centroid.keys())
        length_of_data = len(list(data_for_centroid.values())[0])
        data_list = numpy.empty((number_of_keys, length_of_data))
        for i, data_index in enumerate(data_for_centroid.keys()):
            data_list[i] = data_for_centroid[data_index]
        return data_list

    @staticmethod
    def calculate_mean(input_list):
        # :TODO: Refactor this method so that it works on numpy arrays.
        mean = []
        for i in range(len(input_list[0])):
            vector_for_one_coordinate = [vector[i] for vector in input_list]
            mean.append(sum(vector_for_one_coordinate)/float(len(vector_for_one_coordinate)))
        return mean


def main():
    # mean = [4.56, 5.234]
    # cov = [[1, 0],
    #        [2, 5]]
    # data = numpy.random.multivariate_normal(mean=mean, cov=cov, size=(50, 1))
    # data generation
    data = numpy.vstack((numpy.random.rand(150, 2) + numpy.array([.5, .5]),
                         numpy.random.rand(150, 2) + numpy.array([1, 1]),
                         numpy.random.rand(150, 2)))
    x = [i[0] for i in data]
    y = [i[1] for i in data]

    pyplot.plot(x, y, 'ro')
    pyplot.show()
    g_means = GMeans(log_level='DEBUG')
    g_means.cluster_data(data, max_k=10)


if __name__ == '__main__':
    main()
