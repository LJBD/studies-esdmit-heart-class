function [] = main(dataId)

folder = num2str(dataId)
path('libsvm-windows-dlls/', path); 

directory = fileparts(pwd);
QRSDataPath = fullfile(directory, 'ReferencyjneDane' , folder , 'ConvertedQRSRawData.txt')
QRSClassIdPath = fullfile(directory, 'ReferencyjneDane' , folder , 'Class_IDs.txt')
formatSpec = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
QRSSize = [18 inf];
QRSDataMatrix = GetQRSFromFile(QRSDataPath, formatSpec, QRSSize);
QRSClassIdVector = GetQRSFromFile(QRSClassIdPath, '%f', [inf]);
normalizedQRSComplexes = ConvertToNormalizedQRSComplexesWithId(QRSDataMatrix, QRSClassIdVector);

% % create matrix of featrures X and vector of corresponding labels Y
% [X,Y] = getFeaturesMatrixAndLabelsVector(normalizedQRSComplexes);
Y = zeros(length(normalizedQRSComplexes),1);

X = zeros(length(normalizedQRSComplexes),16);
for i = 1:length(normalizedQRSComplexes)
Y(i) = normalizedQRSComplexes(i).class_id;
X(i,:) = FromRecordToData(normalizedQRSComplexes(i));
end

% Load svm model - REMEMBER TO CREATE APPROPRIATE MODEL
load('models/models.mat');

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

%% Classifing groups
[result, accu, ~] = svmpredict(getClassesFromGroupsMembers(groups, C, X, Y), C, model);

for i = 1:size(C,1)
    % W result s¹ nowe etykiety klas ('przewidziane' przez SVM). 
    % Wektor c_idx jest 'aktualizowany' - takie jakby 'mapowanie'
    % Tzn je¿eli w procesie klasteryzacji powsta³y dwie ró¿ne klasy n1 i
    % n2, to SVM mo¿e uznaæ, ¿e s¹ to te same klasy i scala je nadaj¹c im
    % taki sam indeks - label
    c_idx(c_idx == i) = result(i);
end

figure(2);
%hist([[Y;1;2;3;4], [c_idx;1;2;3;4]],4);
hist([Y,c_idx]);

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
end
