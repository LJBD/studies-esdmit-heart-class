from operator import itemgetter

class QRS_DATA(tuple):
    __slots__ = []

    def __new__(cls, r, r_v, rr_pre, rr_post, p_onset, p_onset_v, p, p_end, p_end_v, qrs_onset, qrs_onset_val, qrs_end, qrs_end_v, t_peak, t_peak_v, t_end, t_end_v): #this is  not qrs data, renme class or try to min argument number
        return tuple.__new__(cls,( r,r_v, rr_pre, rr_post, p_onset, p_onset_v, p, p_end, p_end_v, qrs_onset, qrs_onset_val, qrs_end, qrs_end_v, t_peak, t_peak_v, t_end, t_end_v))

    r_peak = property(itemgetter(0))
    r_peak_value = property(itemgetter(1))
    rr_pre_interval = property(itemgetter(2))
    rr_post_interval = property(itemgetter(3))
    p_onset = property(itemgetter(4))
    p_onset_val = property(itemgetter(5))
    p_peak = property(itemgetter(6))
    p_peak_val = property(itemgetter(7))
    p_end = property(itemgetter(8))
    p_end_val = property(itemgetter(9))
    qrs_onset = property(itemgetter(10))
    qrs_onset_val = property(itemgetter(11))
    qrs_end = property(itemgetter(12))
    qrs_end_val = property(itemgetter(13))
    t_peak = property(itemgetter(14))
    t_peak_val = property(itemgetter(15))
    t_end = property(itemgetter(16))
    t_end_val = property(itemgetter(17))