function dpoint = find_furthest_point( data, point )
%%Finds the furthest point from a given point in a dataset
% Input
%   data   : the data set [NxD], N number of points, D dimension
%   point  : a point (not necessarily in the data set) 
%
% Output
%   dpoint : the data-point furthest away from given point
%
% Copyright 2005-2006 Laboratori d'Aplicacions Bioacustiques
% For more information, errors, comments please contact codas@lab.upc.edu

if ( nargin < 2 )
    error( 'Syntax : dpoint = find_furthest_point( data, point )' );
    return;
end

tdist  = sum((data-repmat(point, size(data,1), 1)).^2,2);
[a,b]  = max(tdist);
dpoint = data(b, :);


