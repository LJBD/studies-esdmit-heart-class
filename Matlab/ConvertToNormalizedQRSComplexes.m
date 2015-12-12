function [ QRSComplxes ] = ConvertToNormalizedQRSComplexes( raw_data )

[rowsLength, columnsLength] = size(raw_data);
normalizedData = zeros(rowsLength, columnsLength);
for i = 1: rowsLength
    rawRowQRS = raw_data(i,:);
    normalizedData(i,:) = (rawRowQRS - min(rawRowQRS))/(max(rawRowQRS) - min(rawRowQRS));
end

normalizedData = normalizedData';

for i = 1 : columnsLength % i know that this is low-efficiency solution
    QRSComplxes(i) = QRSComplex(normalizedData(i,:)) ;
end
end