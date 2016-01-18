__author__ = 'Krystian'

from svm import *


class SVMClassifier:
    def __init__(self):
        self.model = svm_model()
        self.model.free_sv = -1

    def loadSvmModel(self, model_filename):
        self.model = svm_load_model(model_filename)

    def createSvmVector(self, qrs_complex):
        node_list = []

        node_list.append(qrs_complex.p_onset)
        node_list.append(qrs_complex.p_onset_val)
        node_list.append(qrs_complex.p_peak)
        node_list.append(qrs_complex.p_peak_val)
        node_list.append(qrs_complex.p_end)
        node_list.append(qrs_complex.p_end_val)
        node_list.append(qrs_complex.qrs_onset)
        node_list.append(qrs_complex.qrs_onset_val)
        node_list.append(qrs_complex.qrs_end)
        node_list.append(qrs_complex.qrs_end_val)
        node_list.append(qrs_complex.t_peak)
        node_list.append(qrs_complex.t_peak_val)
        node_list.append(qrs_complex.t_end)
        node_list.append(qrs_complex.t_end_val)
        node_list.append(qrs_complex.rr_pre_interval)
        node_list.append(qrs_complex.rr_post_interval)

        return node_list


    def predict(self, qrs_complexes):
        for i in range(0, qrs_complexes.__len__()):
            # Convert data
            x = self.createSvmVector(qrs_complexes[i])
            # Classify
            class_id = int(svm_predict(self.model, x))
            # Save results
            qrs_complexes[i].class_id = class_id
