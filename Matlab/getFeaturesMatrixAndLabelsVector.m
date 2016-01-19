function [X,Y] = getFeaturesMatrixAndLabelsVector(qrs)

feature_number = 18;
number_of_elements = length(qrs);
X(number_of_elements, feature_number)=0;
for i = 1 : number_of_elements
X(i,:) = ToVector(qrs(i));
end

X = X(:,3:18) %without r_peak, r_peak_val

Y = zeros(number_of_elements,1);
for i = 1:number_of_elements
    Y(i) = qrs(i).class_id; 
end
