function status = uploadtoweb(source)
%uploadtoweb		Copy all files in source directory to webserver. The last-most two directories are used
%			to determine the destination directory as follows:
%			source = './worksheets/task1/subtask_plots/' --> dest = 'root/plots/task1/subtask_plots/'
%
% Usage:
%                       uploadtoweb(source)
%
% Input:
%			source = source with images to upload. Relative from directory in which matlab was loaded
%
% Output: 
%			status = status returned from executing scp
%
% Examples:
%			source = './worksheets/finding_realistic_waves/snapshots_plots/';
%                       uploadtoweb(source);

	%Append trailing / to source if not already there (expecting a directory)
	if isdir(source)
		%get last two subdirectories and create destination folder
		if source(end) == '/'
			source = source(1:end-1)
		end
		i1 = find(source == '/', 1, 'last');
		s1 = source(i1+1:end)
		source2 = source(1:i1-1)
		i2 = find(source2 == '/', 1, 'last');
		s2 = source2(i2+1:end)
	        dest = ['lansdell@homer.u.washington.edu:~/public_html/plots/' s2 '_' s1]
	        status = system(['scp -r ' source '/* ' dest]);
	else
		throw(MException('Argin:TypeError', 'source must be a directory'));	
	end
end
