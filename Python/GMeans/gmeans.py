import logging
import numpy
from scipy.cluster.vq import kmeans2
from QRSData import QRSData
from GMeans import anderson_darling_test


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
        self.centroids_to_be_deleted = []

    def cluster_data(self, qrs_complexes, max_k=50, alpha=0.0001):
        """
        The main method of the GMeans class. It is used to cluster data with the G-means algorithm.
        :param qrs_complexes: numpy.array of input data
        :param max_k: maximal number of classes; surpassing this number will cause the algorithm to stop
        :param alpha: significance level of the Anderson-Darling test
        :return centroids: numpy.ndarray of centroids found in the algorithm
        :return labels_dict: dictionary, which keys are indices in the input list of data (qrs_complexes) and values
                            are indices of clusters to which the data point belongs
        :rtype: (numpy.ndarray, numpy.ndarray)
        """
        self.logger.debug('In clusterData')
        self.qrs_data = self.qrs_conversion(qrs_complexes)
        initial_centroid = self.calculate_mean(self.qrs_data)
        self.centroids = numpy.array([initial_centroid])
        self.k = len(self.centroids)

        while self.k < max_k:
            added_to_centroids_flag = False
            self.centroids, labels_for_data = kmeans2(self.qrs_data, k=numpy.array(self.centroids),
                                                      minit='matrix', iter=100)
            self.logger.debug('k-means resulted in centroids: %s' % self.centroids)
            self.set_proper_labels(labels_for_data)

            for centroid_index, centroid in enumerate(self.centroids):
                data_for_centroid = self.get_data_dict_for_centroid(centroid_index)
                if len(list(data_for_centroid.values())) == 0:
                    # if a centroid does not have any points assigned to it, we have to mark it for deletion
                    self.centroids_to_be_deleted.append(centroid_index)
                else:
                    test_outcome, new_centroids, new_labels_for_data = self.run_test(centroid, data_for_centroid, alpha)
                    if test_outcome:
                        self.logger.debug('The test was positive: the old centroid stays.')
                        pass
                    else:
                        self.logger.debug('The test was negative: new centroids will be added.')
                        added_to_centroids_flag = True
                        self.update_after_centroid_addition(centroid_index, data_for_centroid, new_centroids,
                                                            new_labels_for_data)
            self.delete_centroids_with_no_data()
            self.k = len(self.centroids)
            if added_to_centroids_flag is False:
                self.logger.info('GMEANS: I\'ve added nothing, so I\' stopping the algorithm. K = %d' % self.k)
                break
            else:
                pass

        return self.centroids, self.labels_dict

    def delete_centroids_with_no_data(self):
        for index_to_be_deleted in self.centroids_to_be_deleted:
            self.centroids = numpy.delete(self.centroids, index_to_be_deleted, axis=0)
            for key in self.labels_dict.keys():
                if self.labels_dict[key] >= index_to_be_deleted:
                    self.labels_dict[key] -= 1
        self.centroids_to_be_deleted = []

    def update_after_centroid_addition(self, centroid_index, data_for_centroid, new_centroids, new_labels_for_data):
        self.logger.debug('In update_after_centroid_addition')
        # the first centroid gets the old index
        self.centroids[centroid_index] = new_centroids[0]
        # the second is appended at the end
        self.centroids = numpy.append(self.centroids, [new_centroids[1]], axis=0)
        new_centroid_index = len(self.centroids) - 1
        for i, label in enumerate(new_labels_for_data):
            if label == 2:
                data_index_to_be_updated = list(data_for_centroid.keys())[i]
                self.labels_dict[data_index_to_be_updated] = new_centroid_index
            else:
                data_index_to_be_kept = list(data_for_centroid.keys())[i]
                if self.labels_dict[data_index_to_be_kept] != centroid_index:
                    raise ValueError('Mismatching index of centroid for %d!' % data_index_to_be_kept)

    def set_proper_labels(self, labels_for_data):
        self.logger.debug('In set_proper_labels')
        for i, centroid_number in enumerate(labels_for_data):
            self.labels_dict[i] = centroid_number

    def anderson_darling_test(self, data, alpha=0.0001):
        self.logger.debug("In anderson_darling_test")
        return anderson_darling_test.AndersonDarlingTest(data, alpha)

    def run_test(self, centroid, data_for_centroid, alpha=0.0001):
        self.logger.debug("In run_test")
        data_list = self.get_data_list_for_centroid(data_for_centroid)
        child_centroids = self.get_child_centroids(centroid, data_list)
        new_centroids, labels_for_data = kmeans2(data_list, k=child_centroids, iter=100, minit='matrix')
        if len(new_centroids) == 2:
            v = [new_centroids[0][i] - new_centroids[1][i] for i in range(len(new_centroids[0]))]
            projected_data = self.project_data_on_v(data_list, v)
            test_outcome = self.anderson_darling_test(projected_data, alpha)
            return test_outcome, new_centroids, labels_for_data
        else:
            raise ValueError('Unexpected number of centroids (not 2).')

    def project_data_on_v(self, data_list, v):
        self.logger.debug('In project_data_on_v')
        projected_data = numpy.zeros((len(data_list), 1))
        norm_of_v = numpy.linalg.norm(v)
        for i, data_vector in enumerate(data_list):
            dot_product = numpy.dot(v, data_vector)
            projected_data[i] = dot_product/norm_of_v
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
        elif isinstance(qrs_complexes[0], QRSData):
            self.logger.debug('I got QRSData, conversion in progress.')
            number_of_data_vectors = len(qrs_complexes)
            length_of_one_vector = len(qrs_complexes[0].to_ndarray())
            # print('GMEANS: length of one qrs_data vector', length_of_one_vector)
            qrs_array = numpy.zeros((number_of_data_vectors, length_of_one_vector))
            for i, qrs_item in enumerate(qrs_complexes):
                qrs_array[i] = qrs_item.to_ndarray()
            # print('GMEANS: SOME OF THE ARRAY:', qrs_array[:4])
            return qrs_array
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
        mean = []
        for i in range(len(input_list[0])):
            vector_for_one_coordinate = [vector[i] for vector in input_list]
            mean.append(sum(vector_for_one_coordinate)/len(vector_for_one_coordinate))
        return mean


def main():
    # data_a = numpy.random.rand(700, 2) + numpy.array([.5, .5])
    # data_b = numpy.random.rand(700, 2) + numpy.array([1, 1])
    # data_c = numpy.random.rand(700, 2)
    # data = numpy.vstack((data_a, data_b, data_c))
    data = numpy.vstack((numpy.random.rand(1000, 18),
                         numpy.random.rand(1000, 18) + numpy.ones((1, 18))))

    # fig = pyplot.figure()
    # axis = fig.add_subplot(111)
    # data_list = [data_a, data_b, data_c]
    # for i, d in enumerate(data_list):
    #     x = [item[0] for item in d]
    #     y = [item[1] for item in d]
    #     axis.plot(x, y, 'o')
    # pyplot.show()
    g_means = GMeans(log_level='INFO')
    t1 = datetime.datetime.now()
    centroids, labels = g_means.cluster_data(data, max_k=30, alpha=0.01)
    t2 = datetime.datetime.now()
    print('EXECUTION TOOK:', (t2-t1).total_seconds())
    print('I GOT: k = ', len(centroids))
    # print('CENTROIDS', centroids)
    # print('LABELS:', labels)

    # colors = ['r', 'g', 'b', 'c', 'm', 'k', 'y']
    # fig = pyplot.figure()
    # axis = fig.add_subplot(111)
    # axis.set_prop_cycle(cycler('color', colors))
    # big_data_list = []
    # for i, centroid in enumerate(centroids):
    #     axis.plot(centroid[0], centroid[1], 'o')
    #     big_data_list.append([])
    # for key in labels.keys():
    #     big_data_list[labels[key]].append(data[key])
    # axis.set_prop_cycle(cycler('color', colors))
    # for list_for_one_centroid in big_data_list:
    #     x = [item[0] for item in list_for_one_centroid]
    #     y = [item[1] for item in list_for_one_centroid]
    #     axis.plot(x, y, 'x')
    #
    # pyplot.show()


if __name__ == '__main__':
    from matplotlib import pyplot, cycler
    import datetime
    main()
