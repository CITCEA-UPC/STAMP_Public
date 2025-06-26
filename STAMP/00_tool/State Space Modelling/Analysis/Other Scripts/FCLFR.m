function lbd = FCLFR(ss_zsystem,ss_ysystem,FINF,FSUP,STEP,ERROR,OPTION1,OPTION2,NSUB)
%%
%%  v1
%%

syms s
n      = 0;

%%      FREQUENCY

SAMPLES = ceil((FSUP-FINF)/STEP)+1;                                                  % 1 EIG per 1 Hz             
karray  = linspace(FINF,FSUP,SAMPLES)*2*pi(); 
karray(1181) = karray(1180);
%karray(1199) = karray(1198);

s       = 1i*karray;

lbd = {}; %store eig

fwb = waitbar(0.1,'Loading model');

[GRID_matrix] = freqresp(ss_zsystem,s);
[GROWS,GCOLUMNS]    = size(GRID_matrix);
[INPUT_matrix] = freqresp(ss_ysystem,s);
[IROWS,ICOLUMNS]    = size(INPUT_matrix);

waitbar(0.85,fwb,'Sourcer loaded'); 
waitbar(0.9,fwb,'Calculating eigenvalues');    

for k =FINF*2*pi:STEP*2*pi:FSUP*2*pi                                       %    Frequency                                     
    n     = n+1;
        
%%  GNC
  
    G_matrix    = GRID_matrix(1:GROWS,(n*GROWS-(GROWS-1)):n*GROWS);

    Y_source    = INPUT_matrix(1:IROWS,(n*IROWS-(IROWS-1)):n*IROWS);
    
    switch OPTION1
        case 'Z'
                Z_grid   = G_matrix;       

        case 'Y'
                 Z_grid  = G_matrix\eye(length(G_matrix));         
    end  
    
    L_cl     = Z_grid*Y_source;  

    [lambda] = diag(eig(L_cl)); 
    lbd{n} = lambda;
    
    
    nl       = length(lambda);
    fr(n)    = k/(2*pi);
        
% waitbar(k/(FSUP*2*pi),fwb,strcat(string(fr(n)),'Hz'));

%%  PASSIVITY
    switch OPTION2
        case 'PASS'
        F                 = 0.5.*[GRID_matrix(:,:,n) + GRID_matrix(:,:,n)'];
        Lmin_z(n)         = min(eig(F));
        issemiposdef_z(n) = Lmin_z(n)>=0;
        
        F                 = 0.5.*[INPUT_matrix(:,:,n) + INPUT_matrix(:,:,n)'];
        Lmin_y(n)         = min(eig(F));
        issemiposdef_y(n) = Lmin_y(n)>=0;
    end

%%  ORDER EIGS
    
    FEIGFRORDER
    
end
       
%%  PLOT NYQ

    FCLFORMAT
    
%
waitbar(1,fwb,'Complete');
close (fwb)
%
end

