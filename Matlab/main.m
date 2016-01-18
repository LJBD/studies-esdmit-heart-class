
clear all

modelname = 'model111';
packages = [101 111 117 119 201];

model = ReadModel(strcat('../SVM_models/',modelname));

for i=1:length(packages)
    tic;
    DataClassifierForPackage(packages(i), model, false)
    execTime = toc;
    fprintf(strcat('Package: ',num2str(packages(i)),', execution time: ', num2str(execTime),'s\n'))
end