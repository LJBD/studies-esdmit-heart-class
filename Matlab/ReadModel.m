function [ model ] = ReadModel( filename )

    %open file
    fileID = fopen(filename);
    
    %read header
    line = fgets(fileID);
    C = strsplit(line,' ');

    while strcmp(strtrim(C(1)), 'SV') == 0
        cmd = strtrim(C(1));
        val = strtrim(C(2:length(C)));
        
        if strcmp(cmd, 'gamma')
            gamma = val;
            %0 - C-SVC
            %2 - radial basis function
            %0 - degree of rbf
            %0 - coef0 (rbf)
            Parameters = [0;2;0;str2num(char(gamma));0];
        elseif strcmp(cmd, 'nr_class')
            nr_class = str2num(char(val));
        elseif strcmp(cmd, 'total_sv')
            total_sv = str2num(char(val));
        elseif strcmp(cmd, 'rho')
            rho = str2num(char(val));
        elseif strcmp(cmd, 'label')
            label = str2num(char(val));
        elseif strcmp(cmd, 'nr_sv')
            nSV = str2num(char(val));
        end
        
        line = fgets(fileID);
        C = strsplit(line,' ');
    end
    
    %read SVs
    sv_coef = [];
    SVs = [];
    while ~feof(fileID)

        line = fgets(fileID);
        C = strsplit(line,' ');
        
        coefs = str2num(char(C(1:nr_class-1)))';
        sv_coef = [sv_coef;coefs];
        
        sv = C(nr_class:length(C)-1);
        svx = [];
        for i=1:length(sv)
           x = strsplit(char(sv(i)),':');
           svx = [svx, x(2)];
        end
        
        SVs = [SVs; str2num(char(svx))'];
        
    end
    SVs = sparse(SVs);
    
    model.Parameters = Parameters;
    model.nr_class = nr_class;
    model.totalSV = total_sv;
    model.rho = rho;
    model.Label = label;
    model.sv_indices = [];
    model.ProbA = [];
    model.ProbB = [];
    model. nSV = nSV;
    model.sv_coef = sv_coef;
    model.SVs = SVs;
    
end

