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
