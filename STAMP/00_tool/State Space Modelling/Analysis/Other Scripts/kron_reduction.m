%% Eliminate Grid Dynamics
                  
vaps_vells =eig(ss_sys.A);

I_eliminate = [];
I_mantain= [];

ii=1;
jj=1;
for state = 1:1:size(ss_sys.StateName,1)
    if contains(ss_sys.StateName{state},'md')
       I_eliminate(ii) = state;
       ii=ii+1;
    else
       I_mantain(jj) = state;
       jj=jj+1;
    end
end
I_eliminate = nonzeros(I_eliminate);
I_mantain = nonzeros(I_mantain);

       
Aff_v2 = ss_sys.A(I_eliminate,I_eliminate);
Afs_v2 = ss_sys.A(I_eliminate,I_mantain);
Asf_v2 = ss_sys.A(I_mantain,I_eliminate);
Ass_v2 = ss_sys.A(I_mantain,I_mantain);

newA_v2 = Ass_v2-Asf_v2*inv(Aff_v2)*Afs_v2;
vaps_v2 = eig(newA_v2);

%%
figure
scatter(real(vaps_vells),imag(vaps_vells))
hold on
scatter(real(vaps_v2),imag(vaps_v2),'marker','x')
legend('Full','Reduced')

