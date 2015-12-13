%{
THIS IS TEMPORARY MAIN FILE
%}
fullPath = pwd;
directory = fileparts(fullPath);
QRSDataPath = fullfile(directory, '\ReferencyjneDane\101\ConvertedQRSRawData.txt');
formatSpec = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
QRSSize = [18 inf];
QRSDataMatrix = GetQRSFromFile(QRSDataPath, formatSpec, QRSSize);
normalizedQRSComplexes = ConvertToNormalizedQRSComplexes(QRSDataMatrix);
