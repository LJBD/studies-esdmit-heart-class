classdef QRSComplex
    
    properties
        class_id = 2
        r_peak
        r_peak_value
        rr_pre_interval
        rr_post_interval
        p_onset
        p_onset_val
        p_peak
        p_peak_val
        p_end
        p_end_val
        qrs_onset
        qrs_onset_val
        qrs_end
        qrs_end_val
        t_peak
        t_peak_val
        t_end
        t_end_val
    end
    
    methods
        function self = QRSComplex(vector)
            validateattributes(vector,{'numeric'},{'size',[1,18]});
            self.r_peak = vector(1);
            self.r_peak_value = vector(2);
            self.rr_pre_interval = vector(3);
            self.rr_post_interval = vector(4);
            self.p_onset = vector(5);
            self.p_onset_val = vector(6);
            self.p_peak = vector(7);
            self.p_peak_val = vector(8);
            self.p_end = vector(9);
            self.p_end_val = vector(10);
            self.qrs_onset = vector(11);
            self.qrs_onset_val = vector(12);
            self.qrs_end = vector(13);
            self.qrs_end_val = vector(14);
            self.t_peak = vector(15);
            self.t_peak_val = vector(16);
            self.t_end = vector(17);
            self.t_end_val = vector(18);
        end
        
        function vector = ToVector(self)
            vector = [self.r_peak self.r_peak_value self.rr_pre_interval self.rr_post_interval self.p_onset...
                self.p_onset_val self.p_peak self.p_peak_val self.p_end self.p_end_val self.qrs_onset self.qrs_onset_val....
                self.qrs_end self.qrs_end_val self.t_peak self.t_peak_val self.t_end self.t_end_val];
        end
        
        function self = FromVector(vector)
            self = QRSComplex(vector);
        end
    end
    
end

