function [model, Xtest, Ytest] = trainSVM(X,Y,perc) 

    p = randperm(length(X));
    X = X(p,:);
    Y = Y(p);

    train_length = round(length(X) * perc/100);
    Xtrain = X(1:train_length,:);
    Ytrain = Y(1:train_length);
    Xtest = X(train_length+1:end,:);
    Ytest = Y(train_length+1:end);
    
    %% Train 
    gamma = 5 / size(Xtrain,2);
    model = svmtrain(Ytrain, Xtrain, ['-s 0 -c 5 -t 2 -g ', num2str(gamma)]);
       
end