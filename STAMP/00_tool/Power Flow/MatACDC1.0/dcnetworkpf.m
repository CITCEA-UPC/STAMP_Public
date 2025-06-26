function [Vdc, Pdc] = dcnetworkpf(Ybusdc, Vdc, Pdc, slack, noslack, droop, PVdroop, Pdcset, Vdcset, dVdcset, pol, tol, itmax)

%DCNETWORKPF  Runs the dc network power flow.
%   [VDC, PDC, ICC] = DCNETWORKPF(YBUSDC, YFDC, VDC, PDC, SLACK, ...
%       NOSLACK, DROOP, PVDROOP, PDCSET, VDCSET, DVDCSET, POL, TOL, ITMAX)
%
%   Runs the dc network power flow, possibly including several dc grids.
%   Each dc networks can have dc slack buses or several converters in dc
%   voltage control.
%
%   Inputs:
%       YBUSDC : dc network bus matrix, possibly including multiple dc
%           grids
%       VDC : vector with voltages at each dc bus
%       PDC : vector with dc power extractions at each dc bus
%       SLACK : bus number of dc slack buses
%       NOSLACK : bus numbers of non-dc slack buses 
%       DROOP : bus numbers with distributed voltage control
%       PVDROOP : voltage droop gain
%       PDCSET : voltage droop power set-point
%       VDCSET : voltage droop voltage set-point
%       DVDCSET : voltage droop deadband
%       POL : dc grids topology
%           1 = monopolar (asymmetrically grounded)
%           2 = monopolar (symmetrically grounded) or bipolar
%       TOL : Newton's method's tolerance
%       ITMAX :  Newton's method's maximum iterations
%
%   Outputs:
%       VDC : Updated vector with voltages at each dc bus
%       PDC : Updated vector with dc power extractions at each dc bus

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% initialisation
nb       =  length(Vdc);        %% number of dc busses 
Pdc1     = -Pdc;                %% convention on power flow direction
Pdc1(droop) = -Pdcset(droop);   %% droop power set-points
drooplidx   = (droop-ones(length(droop),1))*nb+droop;  % linear droop indices


%%----- dc network iteration -----
%% initialisation
it=0;
converged=0;

%% Newton-Raphson iteration
while ~converged && it<=itmax
     %% update iteration counter
     it = it+1;
     
     %% calculate power injections and Jacobian matrix
     Pdccalc = pol*Vdc.*(Ybusdc*Vdc);
     J       = sparse(pol*Ybusdc.*(Vdc*Vdc'));
     J((1:nb:nb*nb) + (0:nb-1))       = diag(J)+Pdccalc; %replace matrix elements

     %% include droop characteristics
     Vdcsetlh = (abs(Vdc-Vdcset) <= dVdcset).*Vdc+...
                ((Vdc-Vdcset) >  dVdcset).*(Vdcset+dVdcset)+...
                ((Vdc-Vdcset) < -dVdcset).*(Vdcset-dVdcset);    %% define set-point with deadband
    
     Pdccalc(droop) = Pdccalc(droop) + 1./PVdroop(droop).*(Vdc(droop)-Vdcsetlh(droop)); % droop addition 
     J(drooplidx)    = J(drooplidx)+1./PVdroop(droop).*Vdc(droop);

     %% dc network solution
     Jr = J(noslack,noslack);                   %% reduce Jacobian
     dPdcr = Pdc1(noslack)-Pdccalc(noslack);    %% power mismatch vector
     dVr = Jr\dPdcr;                            %% voltage corrections
     
     %% update dc voltages
     Vdc(noslack) = Vdc(noslack).*(ones(size(noslack,1),1)+dVr);
    
    %% convergence check
    if max(abs(dVr))<tol
        converged = 1;
    end
end

%% convergence print
if ~converged
    fprintf(1, '\nDC network power flow did NOT converge after %d iterations\n', it);
end


%%----- Output update -----
%% recalculate slack bus powers
Pdc1(slack) = pol*Vdc(slack).*(Ybusdc(slack,:)*Vdc);
Pdc(slack)  = -Pdc1(slack);

%% recalculate voltage droop bus powers
Pdc1(droop)        = pol*Vdc(droop).*(Ybusdc(droop,:)*Vdc);
Pdc(droop)         = -Pdc1(droop);