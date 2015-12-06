__author__ = 'Krystian'


class QRS_DATA:
    def __init__(self):
        self.class_id = 2   # int
        self.r_peak = None  # doubles...
        self.r_peak_value = None
        self.rr_pre_interval = None
        self.rr_post_interval = None
        self.p_onset = None
        self.p_onset_val = None
        self.p_peak = None
        self.p_peak_val = None
        self.p_end = None
        self.p_end_val = None
        self.qrs_onset = None
        self.qrs_onset_val = None
        self.qrs_end = None
        self.qrs_end_val = None
        self.t_peak = None
        self.t_peak_val = None
        self.t_end = None
        self.t_end_val = None
    
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
