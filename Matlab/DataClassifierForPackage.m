function [] = DataClassifierForPackage(dataId, referenceModel, displayResults)

folder = num2str(dataId);
path('libsvm-windows-dlls/', path); 

directory = fileparts(pwd);
QRSDataPath = fullfile(directory, 'ReferencyjneDane' , folder , 'ConvertedQRSRawData.txt');
QRSClassIdPath = fullfile(directory, 'ReferencyjneDane' , folder , 'Class_IDs.txt');
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

%% Grouping
[groups, C, ad] = gmeans(X, length(X)*0.0005);
c_idx = [];

% Assign to group
for i = 1:length(groups)
    c_idx = [c_idx;i *ones(size(groups{i},1),1)];
end

if displayResults
    % Show results
    figure(1);
    hist(c_idx, linspace(1,length(groups),length(groups))); 
    xlim([0.5 length(groups)+0.5]);
    title('Liczba wektorów cech w poszczególnych klastrach');
end

if displayResults
    svmOptions = '';
else
    svmOptions = '-q';
end
%% Classifing groups
[result, accu, ~] = svmpredict(getClassesFromGroupsMembers(groups, C, X, Y), C, referenceModel, svmOptions);

for i = 1:size(C,1)
    % W result s¹ nowe etykiety klas ('przewidziane' przez SVM). 
    % Wektor c_idx jest 'aktualizowany' - takie jakby 'mapowanie'
    % Tzn je¿eli w procesie klasteryzacji powsta³y dwie ró¿ne klasy n1 i
    % n2, to SVM mo¿e uznaæ, ¿e s¹ to te same klasy i scala je nadaj¹c im
    % taki sam indeks - label
    c_idx(c_idx == i) = result(i);
end

if displayResults
    figure(2);
    subplot(2,1,1);
    hist([c_idx, Y], linspace(1,10,10));
    xlim([0,length(unique(Y))+2]);
    ax = gca;
    ax.XTick = linspace(1,10,10);
    legend('Wyniki przewidywania SVM','Wyniki referencyjne');
    title ('Klasyfikacja reprezentantów klas');
end

model_size = referenceModel.nr_class;
f1_scores = zeros(model_size,1);
% F1 scores for each group
for i = 1:model_size
    precision = sum(c_idx(Y == i) == i)/sum(c_idx == i);
    recall =    sum(c_idx(Y == i) == i)/sum(Y == i);
    f1_scores(i) = 2 * precision*recall/(precision+recall);
end
if displayResults
    display(f1_scores);
end

%% Classifing each qrs
[result, accu, ~] = svmpredict(Y, X, referenceModel, svmOptions);

if displayResults
    %figure(2);
    subplot(2,1,2);
    hist([result, Y], linspace(1,10,10));
    xlim([0,length(unique(Y))+2]);
    ax = gca;
    ax.XTick = linspace(1,10,10);
    legend('Wyniki przewidywania SVM','Wyniki referencyjne');
    title ('Klasyfikacja zespo³ów QRS');
end

model_size = referenceModel.nr_class;
f1_scores = zeros(model_size,1);
% F1 scores for each group
for i = 1:model_size
    precision = sum(result(Y == i) == i)/sum(result == i);
    recall = sum(result(Y == i) == i)/sum(Y == i);
    f1_scores(i) = 2 * precision*recall/(precision+recall);
end

if displayResults
    display(f1_scores);
end
end
