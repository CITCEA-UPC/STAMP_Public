close all;
clc;

clearvars;
load('example_data1.mat')

%% Plot eigenvalue locus (for confirmation)

get_sensitivy_eigenvalues_figure(ss_sys,factor)

%% SMALL-SIGNAL ANALYSIS

input = {'NET.vn1q';'NET.vn1d'};
output = {'VSC1.iq';'VSC1.id'};


l_blocks=l_blocks_list{1,1};
Y_GFL = connect(l_blocks{7},input,output);

input = {'VSC1.iq';'VSC1.id'}; 
output = {'NET.vn1q';'NET.vn1d'};

max_freq=800;
freq_step=0.1;
interpolate_nyquist=0;

for d=1:size(factor,2)
l_blocks=l_blocks_list{1,d};
l_blocks_index=[1:6];
Z_grid{d}= connect(l_blocks{1,l_blocks_index},input,output);
end

%%% Stable case
plot_nyquist(Y_GFL,Z_grid{1,1},max_freq,freq_step,interpolate_nyquist)

%%% Unstable case
plot_nyquist(Y_GFL,Z_grid{1,end},max_freq,freq_step,interpolate_nyquist)