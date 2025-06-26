
% PSCAD vs linear model

clear all;clc;%close all; clc;

% Run power flow
mpc = loadcase('case_sg');
[results] = runpf(mpc);
run PQ_branches
disp('Power flow - Completed')

% Run SG parameters
run SG_param

% Initial values for linear model
run Initial_values_for_linear_model

% 
% % Initialization of Simulink model
% run Init_values_Simulink
% %%
% % Run simulink model
% tstep = 5.1;
% sim_out = sim('Test_SG_circuit_exc_turb');
% % sim_out_stan = sim('Test_SG_standard_v2');
% 
% % Get initial values
% index0 = find(sim_out.ts<tstep,1,'last');
% t0 = sim_out.ts(index0);
% w0 = 2*pi*50;
% w0_pu = 1;
% igq0 = sim_out.ig_q(index0);
% igd0 = sim_out.ig_d(index0);
% vsg_q0 = sim_out.vsg_q(index0);
% vsg_d0 = sim_out.vsg_d(index0);
% isq0 = sim_out.isq(index0);
% isd0 = sim_out.isd(index0);
% ifd0 = sim_out.ifd(index0);
% %e_theta0 = sim_out.e_theta(index0)+pi/2;
% Pm0 = sim_out.Pm(index0);
% 
% isgq0 = sim_out.isg_q(index0);
% isgd0 = sim_out.isg_d(index0);
% 
% vsg_qg0 = sim_out.vsg_qg(index0);
% vsg_dg0 = sim_out.vsg_dg(index0);
% 
% Te0 = sim_out.Te(index0);

% Built linear model
run SS_model_pu.m

% Run linear model
sim_out_lin = sim('Linear_model_v2');

disp('End Simulink simulations')

%% Lectura PSCAD
idx = [2]; % Nº del archivo de las simulaciones a graficar data_idx.txt 
T0 = 0; % Tiempo de inicio del grafico en segundos
Tfin = 30; % Tiempo de final del grafico
tic
data = struct();
j = 1;
for i = idx
    data(1).vars = readtable(strcat('data_',num2str(i),'.txt'),'Delimiter',' ');
    if j == 1 % Seleccion del rango temporal
        t = data.vars.time;
        inicio = sum(t<=T0);
        fin = sum(t<=Tfin);
        ind = inicio:fin;
        t = t(ind);
        pscad.t(:,j) = t;
        clear t
    end

    % SELECCION DE VARIABLES
%     pscad.wm(:,j) = data.vars.wm(ind);
    pscad.Te(:,j) = data.vars.Te(ind);
    pscad.ig_q(:,j) = data.vars.Ig_q(ind)*1000;
    pscad.ig_d(:,j) = data.vars.Ig_d(ind)*1000;
    pscad.e_theta(:,j) = data.vars.e_theta(ind);
    pscad.wm(:,j) = data.vars.wm(ind);
    pscad.P(:,j) = data.vars.Ps(ind);
    pscad.Q(:,j) = data.vars.Qs(ind);
    pscad.vg_q(:,j) = data.vars.Vg_q(ind)*1000;
    pscad.vg_d(:,j) = data.vars.Vg_d(ind)*1000;
    pscad.vsg_q(:,j) = data.vars.Vsg_q(ind)*1000;
    pscad.vsg_d(:,j) = data.vars.Vsg_d(ind)*1000;
    pscad.Ef(:,j) = data.vars.Ef(ind);
    %pscad.vg_a(:,j) = data.vars.Vg_1(ind)*1000;
    %pscad.vsg_a(:,j) = data.vars.Vtn_1(ind)*1000;
    %pscad.isg_a(:,j) = data.vars.Itn_1(ind)*1000;
    
%     pscad.Vsrc(:,j) = data.vars.Vsrc_1(ind);
%     pscad.Vsg(:,j) = data.vars.Vabc_1(ind);
%     pscad.Isg(:,j) = data.vars.Iabc_1(ind);   
%     pscad.P(:,j) = data.vars.P_SG(ind);
%     pscad.Q(:,j) = data.vars.Q_SG(ind);
%     pscad.delta(:,j) = data.vars.loadang(ind);
         
    
    j = j + 1;
end
toc
clear data
disp('Fin de la lectura PSCAD')
T0 = 20;
pscad.t = pscad.t - T0;

%% Plot results
set(0,'defaulttextinterpreter','latex')
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaultLegendInterpreter','latex');
set(0,'defaultAxesFontSize',14)

t0 = 4.1;
tmax = 10;
Lwidth = 1.5;

h = figure;
h.Position = ([1000 100 800 800])
subplot(5,1,1)
% % plot(pscad.t,pscad.ig_q(:,2),'Color','r','Linewidth',Lwidth)
hold on
igq0 = real(Itr)*Ipk*Ssg/Sb;
% plot(sim_out.ts-t0,sim_out.ig_q,'-.','Color',[0.5 0.5 0.5],'Linewidth',Lwidth)
% plot(sim_out_stan.ts-t0,sim_out_stan.ig_q,'--','Color','c','Linewidth',Lwidth)
plot(sim_out_lin.tlin,sim_out_lin.isg_q_lin+igq0,'-.','Color','r','Linewidth',Lwidth)
plot(pscad.t,pscad.ig_q(:,1),'-.','Color',[0 0.5 0],'Linewidth',Lwidth)
xlim([0 tmax])
grid on
xlabel('Time (s)')
ylabel('$i_{g}^q$ (A)')
title('Grid voltage increase (1\%)')
legend('Matlab linear','PSCAD','NumColumns',3)

subplot(5,1,2)
% % plot(pscad.t,pscad.ig_d,'Color',[0.7 0.7 0.7],'Linewidth',Lwidth)
% % plot(pscad.t,pscad.ig_d(:,2),'Color','r','Linewidth',Lwidth)
hold on
igd0 = -imag(Itr)*Ipk*Ssg/Sb;
% plot(sim_out.ts-t0,sim_out.ig_d,'-.','Color',[0.5 0.5 0.5],'Linewidth',Lwidth)
% plot(sim_out_stan.ts-t0,sim_out_stan.ig_d,'--','Color','c','Linewidth',Lwidth)
plot(sim_out_lin.tlin,sim_out_lin.isg_d_lin+igd0,'-.','Color','r','Linewidth',Lwidth)
plot(pscad.t,pscad.ig_d(:,1),'-.','Color',[0 0.5 0],'Linewidth',Lwidth)
xlim([0 tmax])
grid on
xlabel('Time (s)')
ylabel('$i_{g}^d$ (A)')

subplot(5,1,3)
% % plot(pscad.t,pscad.Te(:,2),'Color','r','Linewidth',Lwidth)
hold on
Te0 = Pm0;
% plot(sim_out.ts-t0,sim_out.Te,'-.','Color',[0.5 0.5 0.5],'Linewidth',Lwidth)
% plot(sim_out_stan.ts-t0,sim_out_stan.Te,'--','Color','c','Linewidth',Lwidth)
plot(sim_out_lin.tlin,sim_out_lin.Te_lin+Te0,'-.','Color','r','Linewidth',Lwidth)
plot(pscad.t,pscad.Te(:,1),'-.','Color',[0 0.5 0],'Linewidth',Lwidth)
xlim([0 tmax])
grid on
xlabel('Time (s)')
ylabel('$T_e$ (pu)')

subplot(5,1,4)
% % plot(pscad.t,pscad.e_theta(:,2),'Color','r','Linewidth',Lwidth)
hold on
% plot(sim_out.ts-t0,sim_out.e_theta+e_theta0,'-.','Color',[0.5 0.5 0.5],'Linewidth',Lwidth)
% plot(sim_out_stan.ts-t0,sim_out_stan.e_theta+e_theta0,'--','Color','c','Linewidth',Lwidth)
plot(sim_out_lin.tlin,sim_out_lin.e_theta_lin+e_theta0,'-.','Color','r','Linewidth',Lwidth)
plot(pscad.t,pscad.e_theta(:,1),'-.','Color',[0 0.5 0],'Linewidth',Lwidth)
xlim([0 tmax])
grid on
xlabel('Time (s)')
ylabel('$\Delta \theta$ (rad)')
% legend('PSCAD','Matlab - Eq. circuit', 'Matlab - Standard')

subplot(5,1,5)
% % plot(pscad.t,pscad.wm(:,2)*50,'Color','r','Linewidth',Lwidth)
hold on
% plot(sim_out.ts-t0,sim_out.wm*50,'-.','Color',[0.5 0.5 0.5],'Linewidth',Lwidth)
% plot(sim_out_stan.ts-t0,sim_out_stan.wm*50,'--','Color','c','Linewidth',Lwidth)
plot(sim_out_lin.tlin,sim_out_lin.wm_lin/2/pi+50,'-.','Color','r','Linewidth',Lwidth)
plot(pscad.t,pscad.wm(:,1)*50,'-.','Color',[0 0.5 0],'Linewidth',Lwidth)
xlim([0 tmax])
grid on
xlabel('Time (s)')
ylabel('$f$ (Hz)')
% legend('PSCAD','Matlab - non-linear', 'Matlab - linear')
% legend('PSCAD - Eq. circuit','PSCAD - Standard','Matlab - Eq. circuit', 'Matlab - Standard')
% print('-painters','-depsc','SG_lin_results')
% print('-painters','-dmeta','SG_lin_results') % '-painters' for vectorial graphics

% % % % % %%
% % % % % 
% % % % % set(0,'defaulttextinterpreter','latex')
% % % % % set(groot,'defaultAxesTickLabelInterpreter','latex');  
% % % % % set(groot,'defaultLegendInterpreter','latex');
% % % % % set(0,'defaultAxesFontSize',14)
% % % % % 
% % % % % tmax = 8;
% % % % % Lwidth = 1.5;
% % % % % 
% % % % % h = figure;
% % % % % h.Position = ([1000 100 800 800])
% % % % % 
% % % % % % plot(pscad.t,pscad.Ef(:,1),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % plot(sim_out.ts-t0,sim_out.Ef,'--','Color','b','Linewidth',Lwidth)
% % % % % % plot(sim_out_lin.tlin,sim_out_lin.Ef_lin+Ef0,'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$E_{fd}$ (pu)')
% % % % % 
% % % % % %%
% % % % % 
% % % % % set(0,'defaulttextinterpreter','latex')
% % % % % set(groot,'defaultAxesTickLabelInterpreter','latex');  
% % % % % set(groot,'defaultLegendInterpreter','latex');
% % % % % set(0,'defaultAxesFontSize',14)
% % % % % 
% % % % % t0 = 4.1;
% % % % % tmax = 8;
% % % % % Lwidth = 1.5;
% % % % % 
% % % % % h = figure;
% % % % % h.Position = ([1000 100 800 800])
% % % % % 
% % % % % % plot(pscad.t,pscad.Ef(:,1),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % plot(sim_out.ts-t0,sim_out.Vsg_mag,'--','Color','b','Linewidth',Lwidth)
% % % % % plot(sim_out_lin.tlin,sim_out_lin.Vsg_mag_lin+sim_out.Vsg_mag(index0),'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$E_{fd}$ (pu)')
% % % % % 
% % % % % %%
% % % % % set(0,'defaulttextinterpreter','latex')
% % % % % set(groot,'defaultAxesTickLabelInterpreter','latex');  
% % % % % set(groot,'defaultLegendInterpreter','latex');
% % % % % set(0,'defaultAxesFontSize',14)
% % % % % 
% % % % % tmax = 8;
% % % % % Lwidth = 1.5;
% % % % % 
% % % % % h = figure;
% % % % % h.Position = ([1000 100 800 800])
% % % % % 
% % % % % subplot(2,1,1)
% % % % % plot(pscad.t,pscad.Te(:,1),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % plot(sim_out.ts-4.1,sim_out.Te,'--','Color','b','Linewidth',Lwidth)
% % % % % plot(sim_out_lin.tlin,sim_out_lin.Te_lin+Te0,'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$T_e$ (pu)')
% % % % % 
% % % % % subplot(2,1,2)
% % % % % plot(pscad.t,pscad.e_theta(:,1),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % plot(sim_out.ts-4.1,sim_out.e_theta+e_theta0,'--','Color','b','Linewidth',Lwidth)
% % % % % plot(sim_out_lin.tlin,sim_out_lin.e_theta_lin+e_theta0,'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$\Delta \theta$ (rad)')
% % % % % % legend('PSCAD','Matlab - Eq. circuit', 'Matlab - Standard')
% % % % % 
% % % % % %%
% % % % % h = figure;
% % % % % h.Position = ([1000 100 800 400])
% % % % % subplot(2,1,1)
% % % % % % plot(pscad.t,pscad.P(:,2),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % plot(pscad.t,pscad.P(:,1),'Color','m','Linewidth',Lwidth)
% % % % % plot(sim_out.ts-t0,sim_out.P/1e6,'--','Color','b','Linewidth',Lwidth)
% % % % % % plot(sim_out_stan.ts-5,sim_out_stan.P/1e6,'--','Color','c','Linewidth',Lwidth)
% % % % % % plot(sim_out_lin.tlin,sim_out_lin.P+P0,'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$P$ (MW)')
% % % % % title('Grid voltage increase (1\%)')
% % % % % % legend('PSCAD - Eq. circuit','PSCAD - Standard','Matlab - Eq. circuit', 'Matlab - Standard')
% % % % % legend('PSCAD - Eq. circuit','Matlab - Eq. circuit')
% % % % % 
% % % % % subplot(2,1,2)
% % % % % % plot(pscad.t,pscad.ig_d,'Color',[0.7 0.7 0.7],'Linewidth',Lwidth)
% % % % % % plot(pscad.t,pscad.Q(:,2),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % plot(pscad.t,pscad.Q(:,1),'Color','m','Linewidth',Lwidth)
% % % % % plot(sim_out.ts-t0,sim_out.Q/1e6,'--','Color','b','Linewidth',Lwidth)
% % % % % % plot(sim_out_stan.ts-5,sim_out_stan.Q/1e6,'--','Color','c','Linewidth',Lwidth)
% % % % % % plot(sim_out_lin.tlin,sim_out_lin.ig_d_lin+igd0,'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$Q$ (Mvar)')
% % % % % 
% % % % % %%
% % % % % tmax = 10;
% % % % % Lwidth = 1.5;
% % % % % 
% % % % % h = figure;
% % % % % h.Position = ([1000 100 800 400])
% % % % % subplot(2,1,1)
% % % % % plot(pscad.t,pscad.vg_q(:,1),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % plot(sim_out.ts-5,sim_out.vg_q,'Color','b','Linewidth',Lwidth)
% % % % % % plot(sim_out_stan.ts-5,sim_out_stan.ig_q,'--','Color','c','Linewidth',Lwidth)
% % % % % % plot(sim_out_lin.tlin,sim_out_lin.ig_q_lin+igq0,'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$v_{g}^q$ (V)')
% % % % % title('Grid voltage increase (1\%)')
% % % % % 
% % % % % subplot(2,1,2)
% % % % % % plot(pscad.t,pscad.ig_d,'Color',[0.7 0.7 0.7],'Linewidth',Lwidth)
% % % % % plot(pscad.t,pscad.vg_d(:,1),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % % plot(pscad.t,pscad.vg_d(:,1),'Color','m','Linewidth',Lwidth)
% % % % % plot(sim_out.ts-5,sim_out.vg_d,'Color','b','Linewidth',Lwidth)
% % % % % % plot(sim_out_stan.ts-5,sim_out_stan.ig_d,'--','Color','c','Linewidth',Lwidth)
% % % % % % plot(sim_out_lin.tlin,sim_out_lin.ig_d_lin+igd0,'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$v_{g}^d$ (V)')
% % % % % 
% % % % % %%
% % % % % tmax = 10;
% % % % % Lwidth = 1.5;
% % % % % 
% % % % % h = figure;
% % % % % h.Position = ([1000 100 800 400])
% % % % % subplot(2,1,1)
% % % % % plot(pscad.t,pscad.vsg_q(:,1),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % plot(sim_out.ts-5,sim_out.vsg_q,'Color','b','Linewidth',Lwidth)
% % % % % % plot(sim_out_stan.ts-5,sim_out_stan.ig_q,'--','Color','c','Linewidth',Lwidth)
% % % % % % plot(sim_out_lin.tlin,sim_out_lin.ig_q_lin+igq0,'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$v_{sg}^q$ (V)')
% % % % % title('Grid voltage increase (1\%)')
% % % % % 
% % % % % subplot(2,1,2)
% % % % % % plot(pscad.t,pscad.ig_d,'Color',[0.7 0.7 0.7],'Linewidth',Lwidth)
% % % % % plot(pscad.t,pscad.vsg_d(:,1),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % % plot(pscad.t,pscad.vg_d(:,1),'Color','m','Linewidth',Lwidth)
% % % % % plot(sim_out.ts-5,sim_out.vsg_d,'Color','b','Linewidth',Lwidth)
% % % % % % plot(sim_out_stan.ts-5,sim_out_stan.ig_d,'--','Color','c','Linewidth',Lwidth)
% % % % % % plot(sim_out_lin.tlin,sim_out_lin.ig_d_lin+igd0,'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$v_{sg}^d$ (V)')
% % % % % 
% % % % % 
% % % % % %%
% % % % % tmax = 10;
% % % % % Lwidth = 1.5;
% % % % % 
% % % % % h = figure;
% % % % % h.Position = ([1000 100 800 400])
% % % % % plot(pscad.t,pscad.vsg_a(:,1),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % plot(sim_out.ts-5,sim_out.vsg_abc(:,1),'--','Color','b','Linewidth',Lwidth)
% % % % % % plot(sim_out_stan.ts-5,sim_out_stan.ig_q,'--','Color','c','Linewidth',Lwidth)
% % % % % % plot(sim_out_lin.tlin,sim_out_lin.ig_q_lin+igq0,'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$v_{sg}^a$ (V)')
% % % % % title('Grid voltage increase (1\%)')
% % % % % 
% % % % % %%
% % % % % tmax = 10;
% % % % % Lwidth = 1.5;
% % % % % 
% % % % % h = figure;
% % % % % h.Position = ([1000 100 800 400])
% % % % % plot(pscad.t,pscad.isg_a(:,1),'Color','r','Linewidth',Lwidth)
% % % % % hold on
% % % % % plot(sim_out.ts-5,sim_out.ig_abc(:,1),'Color','b','Linewidth',Lwidth)
% % % % % % plot(sim_out_stan.ts-5,sim_out_stan.ig_q,'--','Color','c','Linewidth',Lwidth)
% % % % % % plot(sim_out_lin.tlin,sim_out_lin.ig_q_lin+igq0,'--','Linewidth',Lwidth)
% % % % % xlim([0 tmax])
% % % % % grid on
% % % % % xlabel('Time (s)')
% % % % % ylabel('$i_{sg}^a$ (V)')
% % % % % title('Grid voltage increase (1\%)')
% % % % % 
% % % % % %%
% % % % % figure
% % % % % plot(sim_out.ts-5,sim_out.ig_q)
% % % % % hold on
% % % % % plot(sim_out_lin.tlin,sim_out_lin.ig_q_lin+igq0)
% % % % % xlim([0 tmax])
% % % % % 
% % % % % figure
% % % % % plot(sim_out.ts-5,sim_out.ig_d)
% % % % % hold on
% % % % % plot(sim_out_lin.tlin,sim_out_lin.ig_d_lin+igd0)
% % % % % xlim([0 tmax])
% % % % % 
% % % % % figure
% % % % % plot(sim_out.ts-5,sim_out.vsg_q)
% % % % % hold on
% % % % % plot(sim_out_lin.tlin,sim_out_lin.vsg_q_lin+vsg_q0)
% % % % % xlim([0 tmax])
% % % % % 
% % % % % figure
% % % % % plot(sim_out.ts-5,sim_out.vsg_d)
% % % % % hold on
% % % % % plot(sim_out_lin.tlin,sim_out_lin.vsg_d_lin+vsg_d0)
% % % % % xlim([0 tmax])
% % % % % 
% % % % % figure
% % % % % plot(sim_out.ts-5,sim_out.vsg_qg)
% % % % % hold on
% % % % % plot(sim_out_lin.tlin,sim_out_lin.vsg_qg_lin+vsg_qg0)
% % % % % xlim([0 tmax])
% % % % % 
% % % % % figure
% % % % % plot(sim_out.ts-5,sim_out.vsg_dg)
% % % % % hold on
% % % % % plot(sim_out_lin.tlin,sim_out_lin.vsg_dg_lin+vsg_dg0)
% % % % % xlim([0 tmax])
% % % % % 
% % % % % figure
% % % % % plot(sim_out.ts-5,sim_out.Te)
% % % % % hold on
% % % % % plot(sim_out_lin.tlin,sim_out_lin.Te_lin+Te0)
% % % % % xlim([0 tmax])
% % % % % 
% % % % % figure
% % % % % plot(sim_out.ts-5,sim_out.e_theta+pi/2)
% % % % % hold on
% % % % % plot(sim_out_lin.tlin,sim_out_lin.e_theta_lin+e_theta0)
% % % % % xlim([0 tmax])
