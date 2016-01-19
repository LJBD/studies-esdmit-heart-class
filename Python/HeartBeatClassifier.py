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
    def __init__(self, modelname):
        self.svm_classifier = SVMClassifier()
        self.svm_classifier.loadSvmModel("../SVM_models/"+modelname)
        self.g_means = gm.GMeans()

    def classify(self, package_number=101):
        # number_of_clusters = 2
        normalized_data = self.getQrsComplexDataFromFile(package_number, 'ConvertedQRSRawData.txt')
        # print('TEST OF IMPORT:', normalized_data[0])
        # print('TEST OF TO_NDARRAY CONVERSION:', normalized_data[0].to_ndarray())

        centroids, labels_dict = self.g_means.cluster_data(normalized_data)
        K = max(labels_dict.values()) + 1
        self.update_data_list(normalized_data, labels_dict)
        self.svm_classifier.predict(normalized_data)

        return K

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
        
    def getQrsComplexDataFromFile(self, package_number, filename):
        dir_to_cpp_signals = os.path.dirname(os.path.dirname(__file__))
        dir_to_cpp_signals = os.path.join('..', 'ReferencyjneDane', str(package_number))
        filename = os.path.join(dir_to_cpp_signals, filename)
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
    fid = open('log', 'a')
    fid.write('\n\n')
    fid.write(str(datetime.datetime.now()))
    fid.write('\n----------------------------------\n')
    fid.write('Package\tTime\t\t\tClusters\n')

    packages = [100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 111, 112, 113, 114, 115, 116, 117, 119, 121, 122, 123, 124, 200, 201, 202, 203, 205, 208, 209, 210, 212, 213, 214, 215, 217, 219, 220, 221, 222, 223, 230, 231, 232, 233, 234];

    hbc = HeartBeatClassifier("model111")

    for i in range(0, len(packages)):
        print('PROCESSING PACKAGE %s' % packages[i])
        t1 = datetime.datetime.now()
        K = hbc.classify(packages[i])
        t2 = datetime.datetime.now()
        exec_time = (t2 - t1).total_seconds()
        fid.write(str(packages[i]) + '\t\t' + str(exec_time) + '\t\t'+str(K) +'\n')
    fid.close()

if __name__ == '__main__':
    main()
