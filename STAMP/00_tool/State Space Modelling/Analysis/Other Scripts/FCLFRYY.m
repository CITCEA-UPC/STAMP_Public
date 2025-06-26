function lbd = FCLFRYY(GRID_ss,INPUT_ss,FINF,FSUP,STEP,ERROR,OPTION1,OPTION2,NSUB)
%%
%%  v1
%%

syms s
n      = 0;

%%      FREQUENCY
if FINF ~= 0
    karray = [logspace(log10(2*pi*FINF),log10(2*pi*59),max(2*FSUP,2000)) logspace(log10(2*pi*61),log10(2*pi*FSUP),max(2*FSUP,18000))]; 
else
    karray = [0 logspace(log10(2*pi*(FINF+1e-10)),log10(2*pi*59),max(2*FSUP,2000)) logspace(log10(2*pi*61),log10(2*pi*FSUP),max(2*FSUP,18000))];  
end

nSamples = length(karray);

% SAMPLES = ceil((FSUP-FINF)/STEP)+1;                                                  % 1 EIG per 1 Hz             
% karray  = linspace(FINF,FSUP,SAMPLES)*2*pi(); 
% karray(1170:1184) = karray(1169);
% %karray(1199) = karray(1198);

s       = 1i*karray;

lbd = {}; %store eig


[GRID_matrix] = freqresp(GRID_ss,s);
[GROWS,GCOLUMNS]    = size(GRID_matrix);
[INPUT_matrix] = freqresp(INPUT_ss,s);
[IROWS,ICOLUMNS]    = size(INPUT_matrix);


for idx = 1:nSamples                                    %    Frequency                                     
    n     = n+1;
    k = karray(idx);    
%%  GNC
  
    G_matrix    = GRID_matrix(1:GROWS,(n*GROWS-(GROWS-1)):n*GROWS);

    Y_source    = INPUT_matrix(1:IROWS,(n*IROWS-(IROWS-1)):n*IROWS);
    
    switch OPTION1
        case 'Z'
                Z_grid   = G_matrix;       

        case 'Y'
                 Z_grid  = G_matrix\eye(length(G_matrix));         
    end  
    
    L_cl     = Z_grid + Y_source;  

    [lambda] = diag(eig(L_cl)); 
    lbd{n} = lambda;
    
    
    nl       = length(lambda);
    fr(n)    = karray(idx)/(2*pi);


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

    FCLFORMATYY
    
end

