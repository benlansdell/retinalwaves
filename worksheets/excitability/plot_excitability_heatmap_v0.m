clf
ic = 'bump';

%Gather data from AUTO auto_excitability.py script
v0s = [-60 -50 -40 -30 -20 -10 0];
load('./worksheets/excitability/excitability_v0_gca_gach_AUTO.mat');
gach = {v0_0_8_gach, v0_0_6_gach, v0_0_5_gach, v0_0_4_gach, v0_0_3_gach, v0_0_2_gach, v0_0_1_gach,v0_0_gach};
gca = {v0_0_8_gca, v0_0_6_gca, v0_0_5_gca, v0_0_4_gca, v0_0_3_gca, v0_0_2_gca,v0_0_1_gca,v0_0_gca};

x = [];
y = [];
z = [];

for idx=1:length(v0s)
	x = [x v0s(idx)*ones(1,length(gach{idx}))];
	y = [y gach{idx}'];
	z = [z gca{idx}'];
end

max(y)
xlin=linspace(min(x),max(x),33);
%ylin=linspace(min(y),max(y),33);
ylin=linspace(0,0.3,33);
[X,Y]=meshgrid(xlin,ylin);
Z=griddata(x,y,z,X,Y,'cubic');
%Z(isnan(Z)) = 0;

%surf(X,Y,Z, 'FaceColor', 'red', 'EdgeColor', 'none'); % interpolated
subplot(1,2,1)
colormap(jet)
pcolor(X,Y,Z)
ylim([0 0.30])
caxis([0 0.7])
xlabel('V_0')
ylabel('g_{ACh}')

%Gather data from excitability.m script
%v0s = [0 -10 -20 -30 -40 -50 -60];
v0s = [-60 -50 -40 -30 -20 -10 0];
gcas = 0:1:24;
gachs = 0:1:9;

load(['./worksheets/excitability/excitability_thresholds_v0_' ic '.mat']);
simulated_data_pts = thresh_pts;
simulated_data = zeros(length(gachs), length(v0s));
for i=1:length(gachs)
	for j=1:length(v0s)
		simulated_data(i,j) = gcas(find(simulated_data_pts(j,:,i), 1, 'first'));	
	end
end
%Non dimensionalize
gKM = 30;
simulated_data = simulated_data/gKM;
gachs = gachs/gKM;

subplot(1,2,2)
xlin=linspace(min(v0s),max(v0s),33);
ylin=linspace(min(gachs),max(gachs),33);
[X,Y]=meshgrid(xlin,ylin);
Z=griddata(v0s,gachs,simulated_data,X,Y,'cubic');

pcolor(X,Y,Z)
caxis([0 0.7])
xlabel('V_0')
ylabel('g_{ACh}')
zlabel('g_{Ca}')

saveplot(gcf, ['./worksheets/excitability/excitability_plots/compare_sim_auto_v0_heatmap_' ic '.eps'], 'eps');
colorbar()
saveplot(gcf, ['./worksheets/excitability/excitability_plots/compare_sim_auto_v0_heatmap_' ic '_colorbar.eps'], 'eps');
%plot2svg(['./worksheets/excitability/excitability_plots/compare_sim_auto_delta.svg'], gcf);
