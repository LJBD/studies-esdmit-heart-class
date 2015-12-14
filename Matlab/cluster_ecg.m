%%This is our Main script i think 

clear variables;
load('SVMModels_libsvm.mat');
path('libsvm-windows-dlls/', path); 
% 119, 201 - super
% 104 - zle
[X,Y] = record2data(201);

%% Grouping
[groups, C, ad] = gmeans(X, length(X)*0.0005);
c_idx = [];

% Assign to group
for i = 1:length(groups)
    c_idx = [c_idx;i *ones(size(groups{i},1),1)];
end

% Show results
figure(1);
hist(c_idx);
% figure(2);
% hist(Y);

%% Classifing groups
[result, accu, ~] = svmpredict((1:length(groups))', C, model);
for i = 1:size(C,1)
    c_idx(c_idx == i) = result(i);
end

figure(2);
hist([[Y;1;2;3;4], [c_idx;1;2;3;4]], 4);


model_size = model.nr_class;
f1_scores = zeros(model_size,1);
% F1 scores for each group
for i = 1:model_size
    precision = sum(c_idx(Y == i) == i)/sum(c_idx == i);
    recall = sum(c_idx(Y == i) == i)/sum(Y == i);
    f1_scores(i) = 2 * precision*recall/(precision+recall);
end
display(f1_scores);

%% Classifing each qrs
[result, accu, ~] = svmpredict(Y, X, model);

figure(3);
hist([result, Y]);

model_size = model.nr_class;
f1_scores = zeros(model_size,1);
% F1 scores for each group
for i = 1:model_size
    precision = sum(result(Y == i) == i)/sum(result == i);
    recall = sum(result(Y == i) == i)/sum(Y == i);
    f1_scores(i) = 2 * precision*recall/(precision+recall);
end
display(f1_scores);