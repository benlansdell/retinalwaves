%Script to plot histograms of the simulations... (plot IWIs, log of wavesize, speed would be nice too...)
x = 0.001:0.01:0.151;
%%Load relevant statistics
load('./simdata/pharma_long_sim_D_0_01_gach_1_5_stats.mat')
iwis_gach_1_5 = iwis;
size_gach_1_5 = histc(wavesizes, x);
sizes_gach_1_5 = wavesizes;
spd_gach_1_5 = wavespds;
load('./simdata/pharma_long_sim_D_0_01_gach_2_66_stats.mat')
iwis_gach_2_66 = iwis;
size_gach_2_66 = histc(wavesizes, x);
sizes_gach_2_66 = wavesizes;
spd_gach_2_66 = wavespds;
load('./simdata/pharma_long_sim_D_0_01_tauach_0_15_stats.mat')
iwis_tauach_0_15 = iwis;
size_tauach_0_15 = histc(wavesizes, x);
sizes_tauach_0_15 = wavesizes;
spd_tauach_0_15 = wavespds;
load('./simdata/pharma_long_sim_D_0_01_tauach_0_266_stats.mat')
iwis_tauach_0_266 = iwis;
size_tauach_0_266 = histc(wavesizes, x);
sizes_tauach_0_266 = wavesizes;
spd_tauach_0_266 = wavespds;
load('./simdata/pharma_long_sim_D_0_01_tausahp_50_stats.mat')
iwis_taus_50 = iwis;
size_taus_50 = histc(wavesizes, x);
sizes_taus_50 = wavesizes;
spd_taus_50 = wavespds;
load('./simdata/pharma_long_sim_D_0_01_tausahp_70_stats.mat')
iwis_taus_70 = iwis;
size_taus_70 = histc(wavesizes, x);
sizes_taus_70 = wavesizes;
spd_taus_70 = wavespds;
load('./simdata/pharma_long_sim_D_0_01_stats.mat')
iwis_def = iwis;
size_def = histc(wavesizes, x);
sizes_def = wavesizes;
spd_def = wavespds;

%%Plot IWIs
clf
ksdensity(iwis_gach_1_5)
hold all
ksdensity(iwis_def)
ksdensity(iwis_gach_2_66)
xlim([0 400])
legend('g_{ACh}^M = 1.5', 'g_{ACh}^M = 2','g_{ACh}^M = 2.66')
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_gach_iwi.eps')

clf
ksdensity(iwis_tauach_0_15)
hold all
ksdensity(iwis_def)
ksdensity(iwis_tauach_0_266)
xlim([0 400])
legend('\tau_{ACh} = 0.15', '\tau_{ACh} = 0.2','\tau_{ACh} = 0.27')
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_tauach_iwi.eps')

clf
ksdensity(iwis_taus_50)
hold all
ksdensity(iwis_def)
ksdensity(iwis_taus_70)
xlim([0 400])
legend('\tau_S = 50', '\tau_S = 60','\tau_{S} = 70')
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_taus_iwi.eps')

%Plot wave sizes
%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf
idx = size_taus_50~=0;
f_taus_50 = polyfit(log10(x(idx)),log10(size_taus_50(idx)'),1);
loglog(x, size_taus_50, '.b', 'MarkerSize', 20);
hold all
loglog(x(1:end-1), 10^f_taus_50(2)*x(1:end-1).^f_taus_50(1), 'LineWidth', 2, 'Color', [0 0 1]);
idx = size_def~=0;
f_def = polyfit(log10(x(idx)),log10(size_def(idx)'),1);
loglog(x, size_def, '.r', 'MarkerSize', 20);
loglog(x(1:end-1), 10^f_def(2)*x(1:end-1).^f_def(1), 'LineWidth', 2, 'Color', [1 0 0]);
idx = size_taus_70~=0;
f_taus_70 = polyfit(log10(x(idx)),log10(size_taus_70(idx)'),1);
loglog(x, size_taus_70, '.', 'MarkerSize', 20, 'Color', [0 0.5 0]);
loglog(x(1:end-1), 10^f_taus_70(2)*x(1:end-1).^f_taus_70(1), 'LineWidth', 2, 'Color', [0 0.5 0]);
legend('\tau_S = 50', '\tau_S = 60','\tau_{S} = 70')
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_taus_size.eps')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot boxplot of log(wavesizes) also...

clf
logsizes = log10([sizes_taus_50; sizes_def; sizes_taus_70]);
g = [ones(size(sizes_taus_50)); 2*ones(size(sizes_def)); 3*ones(size(sizes_taus_70))];
boxplot(logsizes, g);
legend('Taus 50', 'Taus 60', 'Taus 70');
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_taus_size_boxplot.eps');

clf
logsizes = log10([sizes_gach_1_5; sizes_def; sizes_gach_2_66]);
g = [ones(size(sizes_gach_1_5)); 2*ones(size(sizes_def)); 3*ones(size(sizes_gach_2_66))];
boxplot(logsizes, g);
legend('gach 1.5', 'gach 2', 'gach 2.6');
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_gach_size_boxplot.eps');

clf
logsizes = log10([sizes_tauach_0_15; sizes_def; sizes_tauach_0_266]);
g = [ones(size(sizes_tauach_0_15)); 2*ones(size(sizes_def)); 3*ones(size(sizes_tauach_0_266))];
boxplot(logsizes, g);
legend('tauach 0.15', 'tauach 0.2', 'tauach 0.266')
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_tauach_size_boxplot.eps');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot mean and std of wavesizes
clf
means = [mean(sizes_taus_50); mean(sizes_def); mean(sizes_taus_70)];
stds = [std(sizes_taus_50); std(sizes_def); std(sizes_taus_70)];
%errorbar([1 2 3], means, stds);
plot([1 2 3], means, '.');
ylabel('wave size (mm^2)');
legend('Taus 50', 'Taus 60', 'Taus 70');
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_taus_size_means.eps');

clf
means = [mean(sizes_gach_1_5); mean(sizes_def); mean(sizes_gach_2_66)];
stds = [std(sizes_gach_1_5); std(sizes_def); std(sizes_gach_2_66)];
%errorbar([1 2 3], means, stds);
plot([1 2 3], means, '.');
ylabel('wave size (mm^2)');
legend('gach 1.5', 'gach 2', 'gach 2.6');
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_gach_size_means.eps');

clf
means = [mean(sizes_tauach_0_15); mean(sizes_def); mean(sizes_tauach_0_266)];
stds = [std(sizes_tauach_0_15); std(sizes_def); std(sizes_tauach_0_266)];
%errorbar([1 2 3], means, stds);
plot([1 2 3], means, '.');
ylabel('wave size (mm^2)');
legend('tauach 0.15', 'tauach 0.2', 'tauach 0.266')
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_tauach_size_means.eps');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf
idx = size_tauach_0_15~=0;
f_tauach_0_15 = polyfit(log10(x(idx)),log10(size_tauach_0_15(idx)'),1);
loglog(x, size_tauach_0_15, '.b', 'MarkerSize', 20);
hold all
loglog(x(1:end-1), 10^f_tauach_0_15(2)*x(1:end-1).^f_tauach_0_15(1), 'LineWidth', 2, 'Color', [0 0 1]);
idx = size_def~=0;
f_def = polyfit(log10(x(idx)),log10(size_def(idx)'),1);
loglog(x, size_def, '.r', 'MarkerSize', 20);
loglog(x(1:end-1), 10^f_def(2)*x(1:end-1).^f_def(1), 'LineWidth', 2, 'Color', [1 0 0]);
idx = size_tauach_0_266~=0;
f_tauach_0_266 = polyfit(log10(x(idx)),log10(size_tauach_0_266(idx)'),1);
loglog(x, size_tauach_0_266, '.', 'MarkerSize', 20, 'Color', [0 0.5 0]);
loglog(x(1:end-1), 10^f_tauach_0_266(2)*x(1:end-1).^f_tauach_0_266(1), 'LineWidth', 2, 'Color', [0 0.5 0]);
legend('\tau_{ACh} = 0.15', '\tau_{ACh} = 0.2','\tau_{ACh} = 0.266')
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_tauach_size.eps')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf
idx = size_gach_1_5~=0;
f_gach_1_5 = polyfit(log10(x(idx)),log10(size_gach_1_5(idx)'),1);
loglog(x, size_gach_1_5, '.b', 'MarkerSize', 20);
hold all
loglog(x(1:end-1), 10^f_gach_1_5(2)*x(1:end-1).^f_gach_1_5(1), 'LineWidth', 2, 'Color', [0 0 1]);
idx = size_def~=0;
f_def = polyfit(log10(x(idx)),log10(size_def(idx)'),1);
loglog(x, size_def, '.r', 'MarkerSize', 20);
loglog(x(1:end-1), 10^f_def(2)*x(1:end-1).^f_def(1), 'LineWidth', 2, 'Color', [1 0 0]);
idx = size_gach_2_66~=0;
f_gach_2_66 = polyfit(log10(x(idx)),log10(size_gach_2_66(idx)'),1);
loglog(x, size_gach_2_66, '.', 'MarkerSize', 20, 'Color', [0 0.5 0]);
loglog(x(1:end-1), 10^f_gach_2_66(2)*x(1:end-1).^f_gach_2_66(1), 'LineWidth', 2, 'Color', [0 0.5 0]);
legend('g^M_{ACh} = 1.5', 'g^M_{ACh} = 2','g_{ACh}^M = 2.66')
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_gach_size.eps')

%Plot wave speeds...
bw = 0.03;
clf
ksdensity(spd_gach_1_5, 'width', bw)
hold all
ksdensity(spd_def, 'width', bw)
ksdensity(spd_gach_2_66, 'width', bw)
xlim([0 0.3])
legend('g_{ACh}^M = 1.5', 'g_{ACh}^M = 2','g_{ACh}^M = 2.66')
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_gach_spd.eps')

clf
ksdensity(spd_tauach_0_15, 'width', bw)
hold all
ksdensity(spd_def, 'width', bw)
ksdensity(spd_tauach_0_266, 'width', bw)
xlim([0 0.3])
legend('\tau_{ACh} = 0.15', '\tau_{ACh} = 0.2','\tau_{ACh} = 0.27')
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_tauach_spd.eps')

clf
ksdensity(spd_taus_50, 'width', bw)
hold all
ksdensity(spd_def, 'width', bw)
ksdensity(spd_taus_70, 'width', bw)
xlim([0 0.3])
legend('\tau_S = 50', '\tau_S = 60','\tau_{S} = 70')
saveplot(gcf, './worksheets/pharmacology/pharma_long_sims_plots/pharma_taus_spd.eps')

