function [ model ] = TrainModel()
dataId = 101;

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

[model, Xtest, Ytest] = trainSVM(X,Y,85);

%% Test
[result, accu, ~] = svmpredict(Ytest, Xtest, model);
accu
%% Results
model_size = model.nr_class;
f1_scores = zeros(model_size,1);
% F1 scores for group each group
for i = 1:model_size
    precision = sum(result(Ytest == i) == i)/sum(result == i);
    recall = sum(result(Ytest == i) == i)/sum(Ytest == i);
    f1_scores(i) = 2 * precision*recall/(precision+recall);
end
display(f1_scores);

figure(2)
hist([Ytest, result],4);
end