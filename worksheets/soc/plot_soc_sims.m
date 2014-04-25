%Script to plot the distributions of the wave sizes side by side for differen parameter values...

strpt = 1;
x = 0.001:0.01:0.151;
%%Load relevant statistics
load('./simdata/soc_taus_20_stats.mat')
size_taus_20 = histc(wavesizes, x); size_taus_20 = size_taus_20(strpt:end);
load('./simdata/soc_finv_200_stats.mat')
size_finv_200 = histc(wavesizes, x); size_finv_200 = size_finv_200(strpt:end);
load('./simdata/soc_finv_800_stats.mat')
size_def = histc(wavesizes, x); size_def = size_def(strpt:end);
x = x(strpt:end);

%Plot wave sizes
clf
idx = size_taus_20~=0;
f_taus_20 = polyfit(log10(x(idx)),log10(size_taus_20(idx)'),1);
loglog(x, size_taus_20, '.b', 'MarkerSize', 20);
hold all
loglog(x(1:end-1), 10^f_taus_20(2)*x(1:end-1).^f_taus_20(1), 'LineWidth', 2, 'Color', [0 0 1]);
idx = size_def~=0;
f_def = polyfit(log10(x(idx)),log10(size_def(idx)'),1);
loglog(x, size_def, '.r', 'MarkerSize', 20);
loglog(x(1:end-1), 10^f_def(2)*x(1:end-1).^f_def(1), 'LineWidth', 2, 'Color', [1 0 0]);
idx = size_finv_200~=0;
f_finv_200 = polyfit(log10(x(idx)),log10(size_finv_200(idx)'),1);
loglog(x, size_finv_200, '.', 'MarkerSize', 20, 'Color', [0 0.5 0]);
loglog(x(1:end-1), 10^f_finv_200(2)*x(1:end-1).^f_finv_200(1), 'LineWidth', 2, 'Color', [0 0.5 0]);
legend('\tau_S = 20', '', '\tau_S = 60', '', '(\tau_{S} = 60, f^{-1} = 200)', '')
saveplot(gcf, './worksheets/soc/soc_plots/soc_taus_sizes.eps')

display(['Slope for tau_s = 20: ', num2str(f_taus_20(1))])
display(['Slope for tau_s = 60: ', num2str(f_def(1))])
display(['Slope for finv = 200: ', num2str(f_finv_200(1))])

%Plot correlation function too...
clf
load('./simdata/soc_taus_20.mat')
sol = sol{1};
[dd, loess_v_taus_20] = plotcorrelation(sol, './tmp.eps', params);
load('./simdata/soc_finv_800.mat')
sol = sol{1};
[dd, loess_v_taus_60] = plotcorrelation(sol, './tmp.eps', params);
load('./simdata/soc_finv_200.mat')
sol = sol{1};
[dd, loess_v_finv_200] = plotcorrelation(sol, './tmp.eps', params);

clf
plot(dd, 1-loess_v_finv_200, dd, 1-loess_v_taus_60, dd, 1-loess_v_taus_20);
xlim([0 1])
ylim([0 0.3])
xlabel('distance (mm)')
ylabel('correlation')
saveplot(gcf, './worksheets/soc/soc_plots/soc_taus_corr.eps')
