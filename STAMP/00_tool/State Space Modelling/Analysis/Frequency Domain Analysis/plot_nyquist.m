function [] = plot_nyquist(Y_sys,Z_sys,FSUP,STEP,interpolate)

FINF = 0;
fontsize=12;

SAMPLES = ceil((FSUP-FINF)/STEP)+1;                                                  % 1 EIG per 1 Hz             
karray  = linspace(FINF,FSUP,SAMPLES)*2*pi(); 
      
s       = 1i*karray;

[Y_matrix] = freqresp(Y_sys,s);
[Z_matrix] = freqresp(Z_sys,s);

for con2=1:size(Y_matrix,3)
    %%% The -1 in the admittance stands for the opposite current convention
    %%% (load in nyquist criterion while generator in the tool modellig)
    lambda_gen(:,:,con2) = -Y_matrix(:,:,con2)*Z_matrix(:,:,con2) ;
end

[V_EIGEN, D_EIGEN] = eigenshuffle(lambda_gen); 

Lambda1 = D_EIGEN(1,:);
Lambda2 = D_EIGEN(2,:);

real_Lambda1=real(Lambda1);
imag_Lambda1=imag(Lambda1);

real_Lambda2=real(Lambda2);
imag_Lambda2=imag(Lambda2);

%%% Define interpolated vectors for better presentation

% Define Interpolation x-axis

Freq_Ident=karray/2/pi;
Freq_Ident_inter = [1:0.001:Freq_Ident(end)];

% Calculate Complex terms to be plotted

if interpolate
    interpolation_method='pchip';
    
    real_Lambda1_inter =  interp1(Freq_Ident,real_Lambda1,Freq_Ident_inter,interpolation_method);
    imag_Lambda1_inter =  interp1(Freq_Ident,imag_Lambda1,Freq_Ident_inter,interpolation_method);
    
    real_Lambda2_inter =  interp1(Freq_Ident,real_Lambda2,Freq_Ident_inter,interpolation_method);
    imag_Lambda2_inter =  interp1(Freq_Ident,imag_Lambda2,Freq_Ident_inter,interpolation_method);
end

% Circle 
th = 0:pi/50:2*pi;
r = 1;
xunit = r * cos(th) + 0;
yunit = r * sin(th) + 0;

figure ('Name', 'General Nyquist Stability', ...
    'NumberTitle', 'on', ...
    'Position', [1020 200 650 400]);
set(groot, 'DefaultLegendInterpreter', 'latex', 'DefaultLegendFontSize', fontsize);
set(groot, 'DefaultAxesTickLabelInterpreter', 'latex', 'DefaultAxesFontSize', fontsize);


subplot(1,2,1);
plot([real_Lambda1 real_Lambda1],[imag_Lambda1 -imag_Lambda1],'b*')
hold on
if interpolate
    plot([real_Lambda1_inter real_Lambda1_inter],[imag_Lambda1_inter -imag_Lambda1_inter],'b-')
end
plot(xunit, yunit, 'k-');
grid on; 
xlabel('Real','Interpreter','Latex');
set(gca,'FontName','Times','FontSize',fontsize)
ylabel('Imaginary','Interpreter','Latex');
set(gca,'FontName','Times','FontSize',fontsize)
legend('$\lambda_{1}$');
% xlim([-3 3]); ylim([-3 3]);

subplot(1,2,2);
plot([real_Lambda2 real_Lambda2],[imag_Lambda2 -imag_Lambda2],'r*')
hold on
if interpolate
    plot([real_Lambda2_inter real_Lambda2_inter],[imag_Lambda2_inter -imag_Lambda2_inter],'r-')
end
hold on
plot(xunit, yunit, 'k-');
grid on; 
xlabel('Real','Interpreter','Latex');
set(gca,'FontName','Times','FontSize',fontsize)
ylabel('Imaginary','Interpreter','Latex');
set(gca,'FontName','Times','FontSize',fontsize)
legend('$\lambda_{2}$');
%xlim([-3 3]); ylim([-3 3]);

end