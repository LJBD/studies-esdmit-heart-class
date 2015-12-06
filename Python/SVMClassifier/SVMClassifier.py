__author__ = 'Krystian'
from svm import *


class SVMClassifier(object):
    def __init__(self):
        self.model = svm_model()
        self.model.free_sv = -1

    def loadSvmModel(self, model_filename):
        self.model = svm_load_model(model_filename)

    def createSvmVector(self, qrs_complex):
        node_list = []

        node = svm_node(1, qrs_complex.p_onset)
        node_list.append(node)

        node = svm_node(2, qrs_complex.p_onset_val)
        node_list.append(node)

        node = svm_node(3, qrs_complex.p_peak)
        node_list.append(node)

        node = svm_node(4, qrs_complex.p_peak_val)
        node_list.append(node)

        node = svm_node(5, qrs_complex.p_end)
        node_list.append(node)

        node = svm_node(6, qrs_complex.p_end_val)
        node_list.append(node)

        node = svm_node(7, qrs_complex.qrs_onset)
        node_list.append(node)

        node = svm_node(8, qrs_complex.qrs_onset_val)
        node_list.append(node)

        node = svm_node(9, qrs_complex.qrs_end)
        node_list.append(node)

        node = svm_node(10, qrs_complex.qrs_end_val)
        node_list.append(node)

        node = svm_node(11, qrs_complex.t_peak)
        node_list.append(node)

        node = svm_node(12, qrs_complex.t_peak_val)
        node_list.append(node)

        node = svm_node(13, qrs_complex.t_end)
        node_list.append(node)

        node = svm_node(14, qrs_complex.t_end_val)
        node_list.append(node)

        node = svm_node(15, qrs_complex.rr_pre_interval)
        node_list.append(node)

        node = svm_node(16, qrs_complex.rr_post_interval)
        node_list.append(node)

        node = svm_node(-1, None)
        node_list.append(node)

        return node_list

    def predict(self, qrs_complexes):
        it = qrs_complexes[0]
        for i in range(0, it.__len__()):
            # Convert data
            x = self.createSvmVector(it[i])
            # Classify
            class_id = int(svm_predict(self.model, x))
            # Save results
            it[i].class_id = class_id
