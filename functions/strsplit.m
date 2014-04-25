function C = strsplit(str, delimiter)
%STRSPLIT Splits a string into sub strings with specified delimiter
%
% [ Syntax ]
%   - C = strsplit(str)
%   - C = strsplit(str, delimiter)
%
% [ Arguments ]
%   - str:          the source string to be splited
%   - delimiter:    the regular expression of the delimiting string
%   - C:            the cell array of delimited sub strings
%
% [ Description ]
%   - C = strsplit(str) splits the source string str with white spaces.
%     It is equivalent to calling C = strsplit(str, '\s+')
%   
%   - C = strsplit(str, delimiter) splits the source string with the 
%     specified delimiter. The delimiter is given by a string using 
%     regular expression. 
%
% [ Examples ]
%   - Split a string with the terms splitted by white spaces
%     \{
%         strsplit('tiger fish cat') 
%         => {'tiger', 'fish', 'cat'}
%     \}
%     It can also be accomplished by strsplit('tiger fish cat', '\s+')
%
%   - Split a string with the terms splitted by commas
%     \{
%         strsplit('tiger,fish,cat', ',')
%         => {'tiger', 'fish', 'cat'}
%     \}
%     In this case, when there are white spaces around the commas as
%     \{
%         strsplit('tiger, fish , cat', ',')
%         => {'tiger', ' fish ', ' cat'}
%     \}
%     If you would like to consider the spaces around commas as part of
%     the delimiter instead of being part of the splitted strings,
%     you can write as
%     \{
%         strsplit('tiger, fish , cat', '\s*,\s*')
%         => {'tiger', 'fish', 'cat'}
%     \}
%
% [ Remarks ]
%   - If str is empty, it returns an empty cell array.
%
% [ History ]
%   - Created by Dahua Lin, on Jun 26, 2007
%

%% parse and verify input

error(nargchk(1, 2, nargin));

typecheck(str, 'str should be a string or empty', 'string', 'empty');
if nargin < 2
    delimiter = '\s+';
else
    typecheck(delimiter, 'delimiter should be a string', 'string');
end


%% main

if ~isempty(delimiter)
    if ~isempty(str)
        [d_sp, d_ep] = regexp(str, delimiter, 'start', 'end');

        if ~isempty(d_sp)
            C = strsplit_core(str, int32([d_sp; d_ep]));
        else
            C = {str};
        end
    else
        C = {};
    end
else
    error('dmtoolbox:strsplit:emptydelim', 'Delimiter for strsplit cannot be empty.');
end

