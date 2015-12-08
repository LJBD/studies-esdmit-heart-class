function id = class2id(class)
%%Function mapping MIT annotations classes to our classes
% Based on the 'table I' in the article "Automatic Classification of Heartbeats
% Using ECG Morphology and HEartbeat Interval Features" (P. Chalzal,
% M.O'Dwyer, R.B.Reilly)
%
% See also http://www.physionet.org/physiobank/database/html/mitdbdir/intro.htm#annotations

%% Annotations from MIT
classes = ['N', 'L', 'R', 'A', 'a', 'J', 'S', 'V', 'F', '[', '!', ']', 'e', 'j', 'E', '/', 'f', 'x', 'Q', '|'];

%% Mapping them to the our classes
switch class
    case {'N', 'L', 'R', 'e', 'j'}
        id = 1; % Normal beats
    case {'A', 'a', 'J', 'S'}
        id = 1; % Supraventricular ectopic beats
    case {'V', 'E',}
        id = 2; % Ventricular ectopic beats
    case 'F'
        id = 2; % Fusion beats
    case {'/', 'f', 'Q'}
        id = 3; % Unknown beats
    case {'[', ']', '!', 'x', '|'}
        id = 4; % Artifacts
    otherwise
        warning(['Unexpected class!   ', class])
        id = 4; % Artifacts
end

