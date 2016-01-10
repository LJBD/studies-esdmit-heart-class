function ConvertToNormalizedQRSComplexesWithId( raw_data , classId)
sizeOfData = size(raw_data)
normalizedData = zeros(sizeOfData[1], sizeOfData[2]+1)
for i = 1: sizeOfData[1]
    rawRowQRS = raw_data[i,:];
    normalizedData[i,:] = unshift!(collect((rawRowQRS - minimum(rawRowQRS))/(maximum(rawRowQRS) - minimum(rawRowQRS))), classId[i]);
end
normalizedData = normalizedData'
end