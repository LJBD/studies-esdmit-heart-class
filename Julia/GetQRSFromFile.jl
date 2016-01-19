using Logging
function GetQRSFromFile(path, formatSpec)
    info(string("Getting Qrs data from file: ", path))
    QRSData = readdlm(path);
    debug(string("Data read correctly. Data size: ", size(QRSData)))
    return QRSData
end