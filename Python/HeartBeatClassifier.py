import datetime
import os
from sklearn.preprocessing import MinMaxScaler
import GMeans.gmeans as gm
from QRSData import QRSData
from SVMClassifier.SVMClassifier import SVMClassifier
# import sys
# reload(sys)
# sys.setdefaultencoding("utf-8")


class HeartBeatClassifier(object):
    def __init__(self):
        self.svm_classifier = SVMClassifier()
        self.svm_classifier.loadSvmModel("SVMClassifier\\SVM_models\\model111")
        self.g_means = gm.GMeans()

    def classify(self):
        # number_of_clusters = 2
        normalized_data = self.getQrsComplexDataFromFile('ConvertedQRSRawData.txt')
        print('TEST OF IMPORT:', normalized_data[0])
        print('TEST OF TO_NDARRAY CONVERSION:', normalized_data[0].to_ndarray())

        centroids, labels_dict = self.g_means.cluster_data(normalized_data)
        self.update_data_list(normalized_data, labels_dict)
        self.svm_classifier.predict(normalized_data)

    @staticmethod
    def update_data_list(data_list, labels_dict):
        for i, element in enumerate(data_list):
            element.class_id = labels_dict[i]

    @staticmethod
    def array_to_qrs_data(data_array, labels_dict):
        # THIS METHOD IS DEPRECATED. I thought that we'll pass data in numpy.ndarrays but it's not the case.
        qrs_data_list = []
        for i, element in enumerate(data_array):
            qrs = QRSData(element)
            qrs.class_id = labels_dict[i]
            qrs_data_list.append(qrs)
        return qrs_data_list
        
    def getQrsComplexDataFromFile(self, path):
        dir_to_cpp_signals = os.path.dirname(os.path.dirname(__file__))
        dir_to_cpp_signals = os.path.join(dir_to_cpp_signals, 'ReferencyjneDane', '101')
        filename = os.path.join(dir_to_cpp_signals, path)
        with open(filename, "r") as ins:
            qrs_data_list = [QRSData([float(x) for x in line.split()]) for line in ins]
            
        min_max_scaler = MinMaxScaler()    
        r_peak_values = [item.r_peak_value for item in qrs_data_list]
        p_onset_values = [item.p_onset_val for item in qrs_data_list]
        p_peak_values = [item.p_peak_val for item in qrs_data_list]
        p_end_values = [item.p_end_val for item in qrs_data_list]
        qrs_onset_values = [item.qrs_onset_val for item in qrs_data_list]
        qrs_end_values = [item.qrs_end_val for item in qrs_data_list]
        t_peak_values = [item.t_peak_val for item in qrs_data_list]
        t_end_values = [item.t_end_val for item in qrs_data_list]
        scaled_r_peak_values = min_max_scaler.fit_transform(r_peak_values)
        scaled_p_onset_values = min_max_scaler.fit_transform(p_onset_values)
        scaled_p_peak_values = min_max_scaler.fit_transform(p_peak_values)
        scaled_p_end_values = min_max_scaler.fit_transform(p_end_values)
        scaled_qrs_onset_values = min_max_scaler.fit_transform(qrs_onset_values)
        scaled_qrs_end_values = min_max_scaler.fit_transform(qrs_end_values)
        scaled_t_peak_values = min_max_scaler.fit_transform(t_peak_values)
        scaled_t_end_values = min_max_scaler.fit_transform(t_end_values)
        data = []
        for i in range(len(qrs_data_list)):
            tmp = QRSData([qrs_data_list[i].r_peak,
                           scaled_r_peak_values[i],
                           qrs_data_list[i].rr_pre_interval,
                           qrs_data_list[i].rr_post_interval,
                           qrs_data_list[i].p_onset,
                           scaled_p_onset_values[i],
                           qrs_data_list[i].p_peak,
                           scaled_p_peak_values[i],
                           qrs_data_list[i].p_end,
                           scaled_p_end_values[i],
                           qrs_data_list[i].qrs_onset,
                           scaled_qrs_onset_values[i],
                           qrs_data_list[i].qrs_end,
                           scaled_qrs_end_values[i],
                           qrs_data_list[i].t_peak,
                           scaled_t_peak_values[i],
                           qrs_data_list[i].t_end,
                           scaled_t_end_values[i]
                           ])
            data.append(tmp)
        return data

    def run(self):
        pass


def main():
    hbc = HeartBeatClassifier()
    t1 = datetime.datetime.now()
    hbc.classify()
    t2 = datetime.datetime.now()
    exec_time = (t2 - t1).total_seconds()
    print('EXECUTION TIME: ', exec_time)
    # hbc.run()

if __name__ == '__main__':
    main()
