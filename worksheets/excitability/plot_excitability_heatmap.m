ic = 'bump';

%Gather data from AUTO auto_excitability.py script
deltas = [700, 600, 500, 400, 300, 200, 100, 50, 25, 15, 10, 5];
load('excitability_delta_gca_gach.mat');
gach = {delta_700_gach, delta_600_gach, delta_500_gach, delta_400_gach, delta_300_gach, delta_200_gach, delta_100_gach, delta_50_gach, delta_25_gach, delta_15_gach, delta_10_gach, delta_5_gach};
gca = {delta_700_gca, delta_600_gca, delta_500_gca, delta_400_gca, delta_300_gca, delta_200_gca, delta_100_gca, delta_50_gca, delta_25_gca, delta_15_gca, delta_10_gca, delta_5_gca};

x = [];
y = [];
z = [];

for idx=1:length(deltas)
	x = [x deltas(idx)*ones(1,length(gach{idx}))];
	y = [y gach{idx}'];
	z = [z gca{idx}'];
end

xlin=linspace(min(x),max(x),33);
ylin=linspace(min(y),max(y),33);
[X,Y]=meshgrid(xlin,ylin);
Z=griddata(x,y,z,X,Y,'nearest');
%Z(isnan(Z)) = 0;

%surf(X,Y,Z, 'FaceColor', 'red', 'EdgeColor', 'none'); % interpolated
subplot(1,2,1)
colormap(jet)
pcolor(X,Y,Z)
caxis([0 0.7])
xlabel('\delta')
ylabel('g_{ACh}')

%plot3(x,y,z,'.','MarkerSize',15)

%Gather data from excitability.m script
deltas = [800, 100, 50, 25, 15, 10];
gcas = 0:1:24;
gachs = 0:1:9;

load(['./worksheets/excitability/excitability_thresholds_' ic '.mat']);
simulated_data_pts = thresh_pts;
simulated_data = zeros(length(gachs), length(deltas));
for i=1:length(gachs)
	for j=1:length(deltas)
		simulated_data(i,j) = gcas(find(simulated_data_pts(j,:,i), 1, 'first'));	
	end
end

%Non dimensionalize
gKM = 30;
simulated_data = simulated_data/gKM;
gachs = gachs/gKM;

subplot(1,2,2)
xlin=linspace(min(deltas),max(deltas),33);
ylin=linspace(min(gachs),max(gachs),33);
[X,Y]=meshgrid(xlin,ylin);
Z=griddata(deltas,gachs,simulated_data,X,Y,'cubic');

pcolor(X,Y,Z)
caxis([0 0.7])
xlabel('\delta')
ylabel('g_{ACh}')
zlabel('g_{Ca}')
%colorbar()

saveplot(gcf, ['./worksheets/excitability/excitability_plots/compare_sim_auto_delta_heatmap_' ic '.eps'], 'eps');
colorbar()
saveplot(gcf, ['./worksheets/excitability/excitability_plots/compare_sim_auto_delta_heatmap_' ic '_colorbar.eps'], 'eps');
%plot2svg(['./worksheets/excitability/excitability_plots/compare_sim_auto_delta.svg'], gcf);
