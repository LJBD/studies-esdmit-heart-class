path('libsvm-windows-dlls/', path); 

X = [];
Y = [];
for i=1:1000
   x = rand(1,2)*10-5;
   y = 1;
   if x(2)<0
       y = 2;
   end
   if x(1)^2+x(2)^2<4
      y = 3;
   end
   X = [X;x];
   Y = [Y;y];
end

%% Shuffle data
p = randperm(length(X));
X = X(p,:);
Y = Y(p);

train_length = round(length(X) * 0.85);
Xtrain = X(1:train_length,:);
Ytrain = Y(1:train_length);
Xtest = X(train_length+1:end,:);
Ytest = Y(train_length+1:end);

%% plot train set
figure(1);
hold on;
for i=1:size(Xtrain,1)
    switch Ytrain(i)
        case 1
            plot(Xtrain(i,1),Xtrain(i,2),'r*');
        case 2
            plot(Xtrain(i,1),Xtrain(i,2),'g*');
        case 3
            plot(Xtrain(i,1),Xtrain(i,2),'b*');
    end
end
axis([-7,7,-7,7]);

%% train
gamma = 5 / size(X,2);
model = svmtrain(Ytrain, Xtrain, ['-s 0 -c 5 -t 2 -g ', num2str(gamma)]);

%% Test
% pierwszy parametr s³u¿y jedynie do okreœlenia accuracy.
% Z regu³y nie jest znany, bo po co w innym przypadku przewidywaæ
% przynale¿noœæ do grupy, skoro jest znana?
% [result, accu, ~] = svmpredict(Ytest, Xtest, model);
[result, accu, ~] = svmpredict(zeros(length(Ytest),1), Xtest, model);

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


for i = 1:model_size
    display(sprintf('Class %d: -> %d%%',i, round(f1_scores(i)*100) ));
end
figure(2)
hist([Ytest, result],model_size);

%% plot test set
figure(1);
hold on;
for i=1:size(Xtest,1)
    switch result(i)
        case 1
            plot(Xtest(i,1),Xtest(i,2),'ro');
        case 2
            plot(Xtest(i,1),Xtest(i,2),'go');
        case 3
            plot(Xtest(i,1),Xtest(i,2),'bo');
    end
end

axis([-7,7,-7,7]);
grid;
