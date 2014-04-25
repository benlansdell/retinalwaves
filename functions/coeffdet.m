function r2 = coeffdet(xdata, ydata)
	%coeffdet       Computer coefficient of determination for dataset
	%
	% Usage:
	%                       r2 = coeffdet(xdata, ydata)
	%
	% Input:
	%                       xdata = x coordinates of data
	%                       ydata = y coordinates of data
	%
	% Examples:
	%                       x = 1:10; y = randn(1,10);
	%                       r2 = coeffdet(x, y);

	f = polyfit(xdata, ydata, 1);
	yfit = polyval(f, xdata);
	yresid = ydata - yfit;
	SSresid = sum(yresid.^2);
	SStotal  = (length(ydata)-1)*var(ydata);
	r2 = 1 - SSresid/SStotal;

end
