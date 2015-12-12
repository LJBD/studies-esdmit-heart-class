function [ QRSData ] = GetQRSFromFile( path, formatSpec, QRSSize)
[fileID, message] = fopen(path,'r');
QRSData = fscanf(fileID, formatSpec, QRSSize);
fclose(fileID);
end

