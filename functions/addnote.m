function addnote(worksheet, note)
        %addnote		Add note to a worksheet html file for viewing locally. Use in conjuction with addimages to
	%			annotate a series of plots for viewing in a browser
        %
        % Usage:
        %                       addnote(worksheet, note)
        %
        % Input:
        %                       worksheet = name of html file to append note to
        %                       note = string of note to append. Will interpret html
        %
        % Examples:
	%			%As part of a test simulation
        %                       params = parameters('ml_sahp', 'homog', [0:1:100]);
        %                       sol = retinal2D(params);
        %                       plotsol(sol, './worksheets/test/test.gif', params);
	%			addnote('./worksheet/test/test.html', 'What follows is 100s of simulation using the default parameters...
	%						for the Morris Lecar model with sAHP');
	%			addimages('./worksheet/test/test.html', './worksheets/test/test.gif');

	f = fopen(worksheet, 'a');
	fprintf(f, ['<p>' note '</p>']);
	fclose(f);

end
