ic = 'bump';
clf
%Gather data from AUTO auto_excitability.py script
load('excitability_delta_gca_gach.mat');
gach = delta_700_gach;
gca = delta_700_gca;

plot(gach, gca, 'k')
xlabel('g_{ACh}')
ylabel('g_{Ca}')
xlim([0 0.3])
ylim([0 0.8])
hold on

%Gather data from excitability.m script
epsilsons = [1 10 100];
gcas = 0:1:24;
gachs = 0:1:9;

load(['./worksheets/excitability/excitability_thresholds_gachs_gcas_' ic '.mat']);
simulated_data_pts = thresh_pts;
simulated_data = zeros(length(gachs), length(epsilons));
for i=1:length(gachs)
	for j=1:length(epsilsons)
		simulated_data(i,j) = gcas(find(simulated_data_pts(j,:,i), 1, 'first'));	
	end
end

%for i=1:length(epsilons)
%	simulated_data(:,i) = smooth(simulated_data(:,i));
%end

%Non dimensionalize
gKM = 30;
simulated_data = simulated_data/gKM;
gachs = gachs/gKM;

%plot(gachs, simulated_data, '.')
plot(gachs, simulated_data)
legend('singular pert.', '\epsilon = 10^{-3}', '\epsilon = 10^{-4}', '\epsilon = 10^{-5}')
saveplot(gcf, ['./worksheets/excitability/excitability_plots/compare_sim_auto_epsilon.eps']);
