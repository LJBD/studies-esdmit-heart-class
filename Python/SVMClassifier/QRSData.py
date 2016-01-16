import numpy

__author__ = 'Krystian'


class QRSData(object):
    # def __init__(self):
    #     self.class_id = 2   # int
    #     self.r_peak = None  # doubles...
    #     self.r_peak_value = None
    #     self.rr_pre_interval = None
    #     self.rr_post_interval = None
    #     self.p_onset = None
    #     self.p_onset_val = None
    #     self.p_peak = None
    #     self.p_peak_val = None
    #     self.p_end = None
    #     self.p_end_val = None
    #     self.qrs_onset = None
    #     self.qrs_onset_val = None
    #     self.qrs_end = None
    #     self.qrs_end_val = None
    #     self.t_peak = None
    #     self.t_peak_val = None
    #     self.t_end = None
    #     self.t_end_val = None
    
    def __init__(self, arg):
        self.class_id = 2   # int
        self.r_peak = arg[0]
        self.r_peak_value = arg[1]
        self.rr_pre_interval = arg[2]
        self.rr_post_interval = arg[3]
        self.p_onset = arg[4]
        self.p_onset_val = arg[5]
        self.p_peak = arg[6]
        self.p_peak_val = arg[7]
        self.p_end = arg[8]
        self.p_end_val = arg[9]
        self.qrs_onset = arg[10]
        self.qrs_onset_val = arg[11]
        self.qrs_end = arg[12]
        self.qrs_end_val = arg[13]
        self.t_peak = arg[14]
        self.t_peak_val = arg[15]
        self.t_end = arg[16]
        self.t_end_val = arg[17]
        
    def __str__(self):
        return "Class_id " + str(self.class_id)\
        + " r_peak " + str(self.r_peak)\
        + " r_peak_value " + str(self.r_peak_value)\
        + " rr_pre_interval " + str(self.rr_pre_interval)\
        + " rr_post_interval " + str(self.rr_post_interval)\
        + " p_onset " + str(self.p_onset)\
        + " p_onset_val " + str(self.p_onset_val)\
        + " p_peak " + str(self.p_peak)\
        + " p_peak_val " + str(self.p_peak_val)\
        + " p_end " + str(self.p_end)\
        + " p_end_val " + str(self.p_end_val)\
        + " qrs_onset " + str(self.qrs_onset)\
        + " qrs_onset_val " + str(self.qrs_onset_val)\
        + " qrs_end " + str(self.qrs_end)\
        + " qrs_end_val " + str(self.qrs_end_val)\
        + " t_peak " + str(self.t_peak)\
        + " t_peak_val " + str(self.t_peak_val)\
        + " t_end " + str(self.t_end)\
        + " t_end_val " + str(self.t_end_val)

    def to_ndarray(self):
        output_array = numpy.empty((18, 1))
        output_array[0] = self.r_peak
        output_array[1] = self.r_peak_value
        output_array[2] = self.rr_pre_interval
        output_array[3] = self.rr_post_interval
        output_array[4] = self.p_onset
        output_array[5] = self.p_onset_val
        output_array[6] = self.p_peak
        output_array[7] = self.p_peak_val
        output_array[8] = self.p_end
        output_array[9] = self.p_end_val
        output_array[10] = self.qrs_onset
        output_array[11] = self.qrs_onset_val
        output_array[12] = self.qrs_end
        output_array[13] = self.qrs_end_val
        output_array[14] = self.t_peak
        output_array[15] = self.t_peak_val
        output_array[16] = self.t_end
        output_array[17] = self.t_end_val
