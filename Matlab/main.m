
clear all

modelname = 'model111';
packages = [100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 111, 112, 113, 114, 115, 117, 119, 121, 122, 123, 124, 200, 201, 202, 203, 205, 208, 209, 210, 212, 213, 214, 215, 217, 219, 220, 221, 222, 223, 230, 231, 232, 233, 234];
%packages = [210, 212, 213, 214, 215, 217, 219, 220];
model = ReadModel(strcat('../SVM_models/',modelname));
fp = fopen( 'log', 'a' );
fprintf( fp, '\n\n');
fprintf( fp, datestr(datetime('now')));
fprintf( fp, '\n-------------------------------------\n');
fprintf(fp, 'Package\ttime\t\t\tClusters\n');

for i=1:length(packages)
    tic;
    K = DataClassifierForPackage(packages(i), model, false);
    execTime = toc;
    fprintf(fp, strcat(num2str(packages(i)),'\t\t\t', num2str(execTime,'%f'),'\t\t',num2str(K)));
    fprintf( fp, '\n');
end

fclose(fp);