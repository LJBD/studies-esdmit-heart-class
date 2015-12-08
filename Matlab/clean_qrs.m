function [ cleaned_qrs ] = clean_qrs( qrs )
%%Removing Artifacts and QRS complexes with minimum one empty feature
n = 1;

for i = 1:length(qrs)
    if sum(structfun(@isempty,qrs(i))) == 0 && class2id(qrs(i).class) ~= 6
        cleaned_qrs(n) = qrs(i);
        n = n+1;
    end
end
end

