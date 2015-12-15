function [ model ] = TrainModel()
dataId = [111];
directory = fileparts(pwd);
QRSDataMatrix = [];
QRSClassIdVector = [];

for i = 1 : length(dataId)
folder = num2str(dataId(i));
QRSDataPath = fullfile(directory, 'ReferencyjneDane' , folder , 'ConvertedQRSRawData.txt');
QRSClassIdPath = fullfile(directory, 'ReferencyjneDane' , folder , 'Class_IDs.txt');
formatSpec = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
QRSSize = [18 inf];
QRSDataMatrix = [QRSDataMatrix GetQRSFromFile(QRSDataPath, formatSpec, QRSSize);];
QRSClassIdVector = [QRSClassIdVector, GetQRSFromFile(QRSClassIdPath, '%f', [inf])'];
end

normalizedQRSComplexes = ConvertToNormalizedQRSComplexesWithId(QRSDataMatrix, QRSClassIdVector);
Y = zeros(length(normalizedQRSComplexes),1);
X = zeros(length(normalizedQRSComplexes),16);
for i = 1:length(normalizedQRSComplexes)
Y(i) = normalizedQRSComplexes(i).class_id;
X(i,:) = FromRecordToData(normalizedQRSComplexes(i));
end

% Tutaj mozna poprobowac z roznymi proporcjami wektorow cech
% Pamietac zeby w trainSVM zmienic X i Y na newX i new Y
% newX = [];
% newY = [];
% len = length(Y(Y==3));
% 
% for i=1:len*1.25
%     if Y(i) == 1
%         newX = [newX; X(i,:)];
%         newY = [newY; Y(i)];
%     end
% end
% a = 2;
% newX = [newX; X(Y==3,:)];
% newY = [newY; Y(Y==3)];
%                                   A moze 100%?
[model, Xtest, Ytest] = trainSVM(X, Y, 85);

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