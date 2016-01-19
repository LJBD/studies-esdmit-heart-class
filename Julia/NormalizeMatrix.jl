function NormalizeMatrix( raw_data)
    sizeOfData = size(raw_data)
    info(string("Raw data size: ", sizeOfData))
    normalizedData = raw_data
    info(string("Normalized data size: ", size(normalizedData)))
    for i in (2,6,8,10,12,14,16,18)
        rawRowQRS = raw_data[:,i];
        normalizedData[:,i] = collect((rawRowQRS - minimum(rawRowQRS))/(maximum(rawRowQRS) - minimum(rawRowQRS)));
    end
    return normalizedData'
end