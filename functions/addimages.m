function addimages(worksheet, pattern, caption)
        %addimages              Add images to a worksheet html file for viewing locally. Use in conjuction with addnote to
        %                       annotate a series of plots for viewing in a browser
        %
        % Usage:
        %                       addimages(worksheet, images)
        %
        % Input:
        %                       worksheet = name of html file to append note to
        %                       pattern = string of pattern to match. All files matching this pattern will be added to the worksheet
	%			caption = (optional) if provided will add underneath plotted images
        %
        % Examples:
        %                       %As part of a test simulation
        %                       params = parameters('ml_sahp', 'homog', [0:1:100]);
        %                       sol = retinal2D(params);
        %                       plotsol(sol, './worksheets/test/test1.gif', params);
	%			%Change some parameter
	%			params.modelps(17) = 10;
	%			sols = retinal2D_split(params);
	%			plotsol(sol, './worksheets/test/test2.gif', params);
        %                       addnote('./worksheet/test/test.html', 'What follows is 100s of simulation using the default parameters...
        %                                               for the Morris Lecar model with sAHP, and with parameter 17 set to 10.');
        %                       addimages('./worksheet/test/test.html', './worksheets/test/test*.gif');

	if nargin < 3
		caption = '';
	end

	f = fopen(worksheet, 'a');
	fprintf(f, ['<?php addimages("' pattern '", "' caption '"); ?>']);
	fclose(f);

end
