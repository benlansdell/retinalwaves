function iwis = iwi(sol, params, threshold)
        % iwi     Function to identify waves in solution data. Points above a threshold are identified and those adjacent to each
        %
        % Usage:
        %                       iwis = iwi(sol, params, threshold)
        %
        % Input:
        %                       solution = solution matrix output from retinal2D
        %                       params = parameter structure used to generate provided solution
        %                       threshold = (optional, default = 0 [mV]) threshold above which to count voltage as spiking
        %
        % Output:
        %                       iwis = array of iwis for simulation data
        %
        % Example(s):
        %                       params = paramset('ml', 'homog', [0:1:100], 64, 'exponential');
        %                       sol = retinal2D_split(params);
        %                       iwis = iwi(sol, params);

        if (nargin < 2)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
        elseif nargin < 3
                threshold = 0;
        end

	iwis = [];
	border = 6;
	miniwi = 3;
	dt = params.tspan(2) - params.tspan(1);

        Vsol = permute(sol{1}, [2,3,1]);
        active = Vsol > threshold;

        %Spikes occur when activity goes up
        b = (active(:,:,2:end) - active(:,:,1:(end-1)))==1;

        sizeb = size(b);
        for i=border:(sizeb(1)-border)
                for j=border:(sizeb(2)-border)
                        spiketimes = find(b(i,j,:));
                        spiketimes = [0; spiketimes; 0];
                        spikediff = spiketimes(2:end)-spiketimes(1:end-1);
                        spikediff = spikediff(2:end-1);
                        if spikediff*dt > miniwi
                                iwis = [iwis; spikediff*dt];
                        end
                end
        end
end
