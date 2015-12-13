%%This script download files from MIT database and convert them to plain
%%.mat files

clear variables;
%records = [100   101   102   103   104   105   106   107   108   109 ...
%    111   112   113   114   115   116   117   118   119   121   122 ...
%    123   124   200   201   202   203   205   207   208   209   210 ...
%    212   213   214   215   217   219   220   221   222   223   228 ...
%    230   231   232   233   234];

records = [119 201];

physionet_db_url = 'http://www.physionet.org/physiobank/database/';
buffer_size = 10000;
for i = 1:length(records)
    rec_addr = ['mit-bih/', num2str(records(i))];
    mat_addr = ['data/', num2str(records(i)), '.mat'];
    if(~exist(mat_addr, 'file'))
        
        %% Download files
        addr_ext = [rec_addr, '.hea'];
        if(~exist(addr_ext, 'file'))
            urlwrite([physionet_db_url, addr_ext], addr_ext);
        end
        
        addr_ext = [rec_addr, '.dat'];
        if(~exist(addr_ext, 'file'))
            urlwrite([physionet_db_url, addr_ext], addr_ext);
        end
        
        addr_ext = [rec_addr, '.atr'];
        if(~exist(addr_ext, 'file'))
            urlwrite([physionet_db_url, addr_ext], addr_ext);
        end
        
        %% Creating rest of annotations
       
        addr_ext = [rec_addr, '.wqrs'];
        if(~exist(addr_ext, 'file'))
            display([rec_addr, ' creating wqrs annotations']);
            wqrs(rec_addr,[],[],[],[],[],1);
        end
        
        addr_ext = [rec_addr, '.pt'];
        if(~exist(addr_ext, 'file'))
            display([rec_addr, ' creating ecgpuwave annotations']);
            ecgpuwave(rec_addr,'pt',[],[],'wqrs',1);
        end
        
        %% Read data
        display([rec_addr, ' reading - ', num2str(0), '%']);
        % Read signal
        [t, signal] = rdsamp(rec_addr);
        qrs_time = [];
        qrs_class = [];
        qrs_bounds = [];
        qrs_bounds_type = [];
        pt_waves = [];
        pt_type = [];
        
        start = 1;
        finish = start + buffer_size - 1;
        
        while(finish < length(t))
            % Read classes (qrs_time = r_peak_time)
            [qrs_time_batch,qrs_class_batch]=rdann(rec_addr,'atr',[],finish, start);
            qrs_time = [qrs_time; qrs_time_batch];
            qrs_class = [qrs_class; qrs_class_batch];
            
            % Read QRS-onset & QRS-end
            [qrs_bounds_batch,qrs_bounds_type_batch] = rdann(rec_addr,'wqrs',[],finish, start);
            qrs_bounds = [qrs_bounds;qrs_bounds_batch];
            qrs_bounds_type = [qrs_bounds_type;qrs_bounds_type_batch];
            
            % Read P-onset, QRS-end & T-end
            [pt_waves_batch,pt_type_batch] = rdann(rec_addr,'pt',[],finish, start);
            pt_waves = [pt_waves; pt_waves_batch];
            pt_type = [pt_type; pt_type_batch];
            
            start = finish + 1;
            finish = start + buffer_size - 1;
            
            display([rec_addr, ' reading - ', num2str(finish/length(t) * 100), '%']);
        end
        
        %% Compute features
        qrs = [];
        qrs(length(qrs_time)).r_peak = qrs_time(end);
        
        r_peaks = qrs_time;
        
        qrs_onsets = qrs_bounds(qrs_bounds_type == 'N');
        qrs_ends = qrs_bounds(qrs_bounds_type == ')');
        
        temp = (pt_type == 'p');
        p_peaks = pt_waves(temp);
        p_onsets = pt_waves([temp(2:end); false]);
        p_ends = pt_waves([false; temp(1:end-1)]);
        
        temp = (pt_type == 't');
        t_peaks = pt_waves(temp);
        t_ends = pt_waves([false; temp(1:end-1)]);
        
        
        for j = 1:length(r_peaks)
            r_peak = r_peaks(j);
            
            qrs(j).class = qrs_class(j);
            
            if(j == 1)
                prev_peak = 1;
                next_peak = r_peaks(j+1);
            elseif(j == length(r_peaks))
                prev_peak = r_peaks(j-1);
                next_peak = length(t);
            else
                prev_peak = r_peaks(j-1);
                next_peak = r_peaks(j+1);
            end
            
            qrs(j).r_peak = r_peak;
            qrs(j).r_peak_value = signal(r_peak);
            qrs(j).rr_pre_interval = r_peak - prev_peak;
            qrs(j).rr_post_interval = next_peak - r_peak;
            
            p_onset = p_onsets(p_onsets < r_peak & p_onsets > prev_peak) - r_peak;
            if length(p_onset) > 1
                p_onset = p_onset(end);
            end
            qrs(j).p_onset = p_onset;
            qrs(j).p_onset_val = signal(p_onset + r_peak);
            
            p_peak = p_peaks(p_peaks < r_peak & p_peaks > prev_peak) - r_peak;
            if length(p_peak) > 1
                p_peak = p_peak(end);
            end
            qrs(j).p_peak = p_peak;
            qrs(j).p_peak_val = signal(p_peak + r_peak);
            
            p_end = p_ends(p_ends < r_peak & p_ends > prev_peak) - r_peak;
            if length(p_end) > 1
                p_end = p_end(end);
            end
            qrs(j).p_end = p_end;
            qrs(j).p_end_val = signal(p_end + r_peak);
            
            qrs_onset = qrs_onsets(qrs_onsets < r_peak & qrs_onsets > prev_peak) - r_peak;
            if length(qrs_onset) > 1
                qrs_onset = qrs_onset(end);
            end
            qrs(j).qrs_onset = qrs_onset;
            qrs(j).qrs_onset_val = signal(qrs_onset + r_peak);
            
            qrs_end = qrs_ends(qrs_ends < next_peak & qrs_ends > r_peak) - r_peak;
            if length(qrs_end) > 1
                qrs_end = qrs_end(1);
            end
            qrs(j).qrs_end = qrs_end;
            qrs(j).qrs_end_val = signal(qrs_end + r_peak);
            
            t_peak = t_peaks(t_peaks < next_peak & t_peaks > r_peak) - r_peak;
            if length(t_peak) > 1
                t_peak = t_peak(1);
            end
            qrs(j).t_peak = t_peak;
            qrs(j).t_peak_val = signal(t_peak + r_peak);
            
            t_end = t_ends(t_ends < next_peak & t_ends > r_peak) - r_peak;
            if length(t_end) > 1
                t_end = t_end(1);
            end
            qrs(j).t_end = t_end;
            qrs(j).t_end_val = signal(t_end + r_peak);
            
            if mod(j,100) == 0
                display([rec_addr, ' computing features - ', num2str(j/length(r_peaks) * 100), '%']);
            end
        end
        display([rec_addr, ' computing features - ', num2str(100), '%']);
        %% Save to .mat
        save(mat_addr, 't', 'signal', 'qrs');
    end
end


% class - .atr
% R-peaks - .atr
% QRS-onset - wqrs
% QRS-end - wqrs
% T-peak - ecgpuwave
% T-end - ecgpuwave
% P-onset - ecgpuwave
% P-peak - ecgpuwave
% P-end - ecgpuwave