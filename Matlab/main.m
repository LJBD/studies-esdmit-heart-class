%{
THIS IS TEMPORARY MAIN FILE
%}
fullPath = pwd;
directory = fileparts(fullPath);
QRSDataPath = fullfile(directory, '\ReferencyjneDane\101\ConvertedQRSRawData.txt');
formatSpec = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
QRSSize = [18 inf];
QRSDataMatrix = GetQRSFromFile(QRSDataPath, formatSpec, QRSSize);
normalizedQRSComplexes = ConvertToNormalizedQRSComplexes(QRSDataMatrix);

% create matrix of featrures X and vector of corresponding labels Y
[X,Y] = getFeaturesMatrixAndLabelsVector(normalizedQRSComplexes);

% Load svm model - REMEMBER TO CREATE APPROPRIATE MODEL
load('SVMModels_libsvm.mat');

%% Grouping
[groups, C, ad] = gmeans(X, length(X)*0.0005);
c_idx = [];

% Assign to group
for i = 1:length(groups)
    c_idx = [c_idx;i *ones(size(groups{i},1),1)];
end

% Show results
figure(1);
subplot(2,1,1);  hist(c_idx);   %"not recommended; use histogram"
subplot(2,1,2);  histogram(c_idx); 
% figure(4);
% hist(Y);

%% Classifing groups
[result, accu, ~] = svmpredict(C(:,1), C, model);

for i = 1:size(C,1)
    c_idx(c_idx == i) = result(i);
end

figure(2);
hist([[Y;1;2;3;4], [c_idx;1;2;3;4]],4);

model_size = model.nr_class;
f1_scores = zeros(model_size,1);
% F1 scores for each group
for i = 1:model_size
    precision = sum(c_idx(Y == i) == i)/sum(c_idx == i);
    recall =    sum(c_idx(Y == i) == i)/sum(Y == i);
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