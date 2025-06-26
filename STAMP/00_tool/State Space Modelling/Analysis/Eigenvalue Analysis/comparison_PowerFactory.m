T_PF = readtable("modes_digsilent.xlsx");

T_PF=T_PF(~any(ismissing(T_PF),2),:);

D = eig(ss_sys.A);
%D_rms = eig(ss_sys_rms.A);
figure
scatter(real(D),imag(D))
hold on
%scatter(real(D_rms),imag(D_rms),'Marker','+')
%hold on
scatter(T_PF{:,2},T_PF{:,3},'marker','x')
ylim([-10 10])
xlim([-3 0.1])
grid on
legend('STAMP','PowerFactory')
ylabel('Imag')
xlabel('Real')

FMODAL_REDUCED(ss_sys,[13,14,15,16,17])
