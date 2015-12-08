%%Simple script for plotting ecg signal with marked points

clear all variable;
load('data/223.mat');

figure(1)
plot(t,signal(:,1));hold on;grid on;
plot(t([qrs.r_peak]),signal([qrs.r_peak]),'or')

for i = 1:length(qrs)
    if isempty(qrs(i).p_onset)
        qrs(i).p_onset = 0;
    end
    if isempty(qrs(i).p_end)
        qrs(i).p_end = 0;
    end
    if isempty(qrs(i).qrs_onset)
        qrs(i).qrs_onset = 0;
    end
    if isempty(qrs(i).qrs_end)
        qrs(i).qrs_end = 0;
    end
    if isempty(qrs(i).t_end)
        qrs(i).t_end = 0;
    end
end

p_onset = [qrs.r_peak] + [qrs.p_onset];
p_end = [qrs.r_peak] + [qrs.p_end];
qrs_onset = [qrs.r_peak] + [qrs.qrs_onset];
qrs_end = [qrs.r_peak] + [qrs.qrs_end];
t_end = [qrs.r_peak] + [qrs.t_end];

plot(t(p_onset),signal(p_onset),'ob')
plot(t(p_end),signal(p_end),'om')
plot(t(qrs_onset),signal(qrs_onset),'oy')
plot(t(qrs_end),signal(qrs_end),'og')
plot(t(t_end),signal(t_end),'oc')
hold off;

figure(2)
[index,keys] = grp2idx({qrs.class})
hist(index);