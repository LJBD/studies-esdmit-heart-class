function [X,Y] = record2data(record_id)
%%Construction of static data from ECG recording 
mat_addr = ['data/', num2str(record_id), '.mat'];
load(mat_addr);

qrs = clean_qrs(qrs);
feature_number = 16;
number_of_elements = length(qrs);
X = zeros(number_of_elements, feature_number);

% p_onest time and value
X(:,1) = [qrs.p_onset];
X(:,2) = [qrs.p_onset_val];

% p_peak time and value
X(:,3) = [qrs.p_peak];
X(:,4) = [qrs.p_peak_val];

% p_end time and value
X(:,5) = [qrs.p_end];
X(:,6) = [qrs.p_end_val];

% qrs_onset time and value
X(:,7) = [qrs.qrs_onset];
X(:,8) = [qrs.qrs_onset_val];

% qrs_end time and value
X(:,9) = [qrs.qrs_end];
X(:,10) = [qrs.qrs_end_val];

% t_peak time and value
X(:,11) = [qrs.t_peak];
X(:,12) = [qrs.t_peak_val];

% t_end time and value
X(:,13) = [qrs.t_end];
X(:,14) = [qrs.t_end_val];

% rr_intervals
X(:,15) = [qrs.rr_pre_interval];
X(:,16) = [qrs.rr_post_interval];

% Normalize
% for i = 1:feature_number
%     vec = X(:,i);
%     vec = vec - mean(vec);
%     vec = vec/std(vec);
%     X(:,i) = vec;
% end

Y = zeros(number_of_elements,1);
for i = 1:number_of_elements
    Y(i) = class2id(qrs(i).class);
end
