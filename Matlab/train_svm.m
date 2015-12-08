%%Script containing all process of training multiclass SVM classifier based
%%on data from MIT

records_train = [100   101   102   103  106   107   108   109 ...
    111   115   116   117   118   119   121   122 ...
    124   200   202   203   205   207   209   210 ...
    212   213   215   217   219   221   222   223   228 ...
    230   231   232   233   234 123 201 208 214 113 105];

records_test = [220 104 112 114];

%% Collect all qrs and normalize them X and Y (class)
X = []; Y = [];
Xtrain = []; Ytrain = [];
Xval = []; Yval = []; % Validation data are not used for now
Xtest = []; Ytest = [];

% All data
for i = 1:length(records_train)
    [X_batch,Y_batch] = record2data(records_train(i));
    X = [X;X_batch] ; Y = [Y;Y_batch];
end

% % Train data
% for i = 1:length(records_train)
%     [X_batch,Y_batch] = record2data(records_train(i));
%     Xtrain = [Xtrain;X_batch] ; Ytrain = [Ytrain;Y_batch];
% end
% 
% % Test data
% for i = 1:length(records_test)
%     [X_batch,Y_batch] = record2data(records_test(i));
%     Xtest = [Xtest;X_batch] ; Ytest = [Ytest;Y_batch];
% end

%% Shuffle data
p = randperm(length(X));
X = X(p,:);
Y = Y(p);

train_length = round(length(X) * 0.85);
Xtrain = X(1:train_length,:);
Ytrain = Y(1:train_length);
Xtest = X(train_length+1:end,:);
Ytest = Y(train_length+1:end);

%% Train 
path('libsvm/', path); 
gamma = 5 / size(Xtrain,2);
model = svmtrain(Ytrain, Xtrain, ['-s 0 -c 5 -t 2 -g ', num2str(gamma)]);

%% Save SVM
save('SVMModels_libsvm.mat', 'model');

%% Test
[result, accu, ~] = svmpredict(Ytest, Xtest, model);
accu
%% Results
model_size = model.nr_class;
f1_scores = zeros(model_size,1);
% F1 scores for group each group
for i = 1:model_size
    precision = sum(result(Ytest == i) == i)/sum(result == i)
    recall = sum(result(Ytest == i) == i)/sum(Ytest == i)
    f1_scores(i) = 2 * precision*recall/(precision+recall);
end
display(f1_scores);

figure(2)
hist([Ytest, result],4);