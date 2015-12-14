function [X,Y] = getFeaturesMatrixAndLabelsVector(qrs)

feature_number = 18;
number_of_elements = length(qrs);
X(number_of_elements, feature_number)=0;
for i = 1 : number_of_elements
X(1,:) = ToVector(qrs(i));
end

Y = zeros(number_of_elements,1);
for i = 1:number_of_elements
    Y(i) = qrs(i).class_id; % to zawsze bedzie 2 !! Tak chyba nie powinno byæ , tutaj skrypt class2id powinien byc wywo³any
end
