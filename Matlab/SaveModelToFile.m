function [] = SaveModelToFile(Model,filename)
    fp = fopen( filename, 'wt' );
    
    %% Header
    fprintf( fp, 'svm_type c_svc\nkernel_type rbf\ngamma ');
    fprintf( fp, strcat(num2str(Model.Parameters(4)),'\n'));
    s = size(Model.SVs);
    fprintf( fp, 'nr_class ');  fprintf(fp, num2str(Model.nr_class));   fprintf(fp, '\n');
    fprintf( fp, 'total_sv ');  fprintf(fp, num2str(s(1))); fprintf(fp, '\n');
    fprintf( fp, 'rho ');
    for i=1:length(Model.rho)
        fprintf( fp, num2str(Model.rho(i)));
        if i~= length(Model.rho)
            fprintf(fp, ' ');
        else
            fprintf(fp, '\n');
        end
    end
    fprintf( fp, 'label ');
    for i=1:length(Model.Label)
        fprintf( fp, num2str(Model.Label(i)));
        if i~= length(Model.Label)
            fprintf(fp, ' ');
        else
            fprintf(fp, '\n');
        end
    end
    fprintf( fp, 'nr_sv ');
    for i=1:length(Model.nSV)
        fprintf( fp, num2str(Model.nSV(i)));
        if i~= length(Model.nSV)
            fprintf(fp, ' ');
        else
            fprintf(fp, '\n');
        end
    end
    fprintf( fp, 'SV\n');
    
    %% SVs
    coefsSize = size(Model.sv_coef(1,:));
    coefsSize = coefsSize(2);
    SVSize = size(Model.SVs(1,:));
    SVSize = SVSize(2);
    for i=1:Model.totalSV     
        for j=1:coefsSize
            fprintf(fp, num2str(Model.sv_coef(i,j)));
            fprintf(fp, ' ');
        end
        for j=1:SVSize
            fprintf(fp, num2str(j));
            fprintf(fp, ':');
            fprintf(fp, num2str(Model.SVs(i,j)));
            if j~= SVSize
                fprintf(fp, ' ');
            else
                fprintf(fp, '\n');
            end
        end
    end
    fprintf(fp, '\0');
    
    
    fclose(fp);
end