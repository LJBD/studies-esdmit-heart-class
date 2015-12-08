function result = multisvm_classify(SVMModels, Xtest)
%%Multi class svm classification
result = zeros(size(Xtest,1),1);

for j = 1:size(Xtest,1);
    for k = 1:length(SVMModels)
        if(svmclassify(SVMModels(k),Xtest(j,:)))
            break; % Tu mozma zmienic aby robilo do konca i wybieralo najwiekszy scoring;
        end
    end
    result(j) = k;
end


