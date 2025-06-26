close all;
clc;

clearvars;
load('example_data2.mat')

%% Plot eigenvalue locus (for confirmation)

get_sensitivy_eigenvalues_figure(ss_sys,factor)

%% SMALL-SIGNAL ANALYSIS

input = {'NET.vn4q';'NET.vn4d'};
output = {'VSC1.iq';'VSC1.id'};

for d=1:size(factor,2)
l_blocks=l_blocks_list{1,d};
Y_GFM{d} = connect(l_blocks{6},input,output);
end
max_freq=1.8e3;
freq_step=0.1;
transfer_function_type='Admittance';
plot_only_pp=1;

%%% This is important in order to account for the difference in the current
%%% convention. Converters are generally considered a load for admittance
%%% analysis while the tool models them as generators

scale=-1;

plot_impedance_sensitivities_pn(Y_GFM,factor,max_freq,freq_step,transfer_function_type,plot_only_pp,scale)
plot_impedance_sensitivities_qd(Y_GFM,factor,max_freq,freq_step,transfer_function_type,plot_only_pp,scale)
plot_passivity_sensitivities(Y_GFM,factor,max_freq,freq_step,scale)

% 
% input = {'VSC1.iq';'VSC1.id'}; 
% output = {'NET.vn4q';'NET.vn4d'};
% 
% l_blocks=l_blocks_list{1,1};
% l_blocks_index=[1 2 3 4 5 7];
% Z_grid= connect(l_blocks{1,l_blocks_index},input,output);
% 
% plot_nyquist(Y_GFM{1,end},Z_grid,max_freq,freq_step)
