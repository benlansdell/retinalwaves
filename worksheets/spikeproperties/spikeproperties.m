%Script to determine wave speed, spike duration, max S and threshold S for our default
%parameters

threshold = 0;
tmax = 10;
n = 64;
L = 2;
D = 0.005;

%setup default parameters
params = parameters('ml_sahp', 'bump', 0:0.1:tmax, n, 'none');
%make diffusion coeff smaller:
params.diffusion_coeff = D;
params.modelps(16) = D;
%run simulation
sol = retinal2D_split(params);
vsol = sol{1};
ssol = sol{3};

%figure out wave speed by comparing two points
midpt = vsol(:,32,32);
endpt = vsol(:,32,5);
smidpt = ssol(:,32,32);

uptime_mid = find(midpt > threshold, 1, 'first');
downtime_mid = find(midpt > threshold, 1, 'last');
uptime_end = find(endpt > threshold, 1, 'first');
downtime_end = find(endpt > threshold, 1, 'last');

speed = L*length(midpt)*sqrt((32-5)^2+(32-32)^2)/(uptime_end-uptime_mid)/tmax/n

%figure out \tau by comparing same point at different threshold crossing times
tau = tmax*(downtime_mid-uptime_mid)/length(midpt)

%figure out S_m by simply taking max at a point during wave
S_m = max(smidpt)

%run different set of simulations to figure out S_t
%start with a lot of different initial S values, and with a bump on one side. 
%find the value of S at which a wave makes it to the other side....

%run simulation with setting S constant... make a new model for this
Ss = 0:(S_m/20):S_m;
excitable = [];
tmax = 20;
for s = Ss
	%setup default parameters
	params = parameters('ml_sahp_fixed_s', 'bump', 0:0.1:tmax, n, 'none');
	%load different ICs
	params.ics{3} = s*ones(n,n);
	%make diffusion coeff smaller:
	params.diffusion_coeff = D;
	params.modelps(16) = D;
	%run simulation
	sol = retinal2D_split(params);
	vsol = sol{1};
	%test if wave makes it to the end...
	endpt = vsol(:,32,5);
	excitable = [excitable any(endpt>threshold)];
end
idx = find(excitable, 1, 'last');
S_T = Ss(idx)
