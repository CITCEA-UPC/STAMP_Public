function [Ps, Qc, Vc]=calcslackdroop(Pcspec, Qsspec, Vs, Vf, Vc, Ztf, Bf, Zc, tol, itmax)

%CALCSLACK Internal slack/droop bus power injection iteration.
%    [PS, QC, VC]=CALCSLACKDROOP(PCSPEC, QSSPEC, VS, VF, VC, ZTF, BF, ZC, TOL, ITMAX)
%
%   Internal Newton-Raphson iteration to calculate the slack buses and 
%   voltage droop controlled buses power injections in the ac grid using
%   the converter active power injection and the ac grid state (Vs) and the
%   reactive power injection as fixed values.
%
%   Inputs:
%       PCSPEC : specified converter active power injection
%       QSSPEC : specified grid side reactive power injection
%       VS : grid side complex voltage
%       VF : filter complex voltage
%       VC : converter complex voltage
%       ZTF : converter transformer complex impedance
%       BF : filter susceptance
%       ZC : phase reactor complex impedance
%       TOL : Newton's method's tolerance
%       ITMAX :  Newton's method's maximum iterations
%
%   Outputs:
%       PS : grid side active power injection
%       QC : converter side reactive power injection
%       VC : converter complex voltage

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

% Approach based on: 
% J. Beerten, S. Cole and R. Belmans: "Generalized Steady-State VSC MTDC 
% Model for Sequential AC/DC Power Flow Algorithms", IEEE Trans. Pow.
% Syst., vol. 27, no. 2, 2012, pp. 821 - 829.

%%----- initialise -----
%% define number of slack/droop buses
ng  = length(Pcspec);

%% define matrix indices
i1 = [1:ng]';
i2 = [ng+1:2*ng]';
i3 = [2*ng+1:3*ng]';
i4 = [3*ng+1:4*ng]';

%% define voltage amplitudes and angles
Vsm = abs(Vs);      %% grid voltage amplitude
Vsa = angle(Vs);    %% grid voltage angle
Vfm = abs(Vf);      %% filter voltage amplitude
Vfa = angle(Vf);    %% filter voltage angle
Vcm = abs(Vc);      %% converter voltage amplitude
Vca = angle(Vc);    %% converter voltage angle

%% calculate converter admitance
Yc = 1./Zc;
Gc = real(Yc);
Bc = imag(Yc);

%% determine converters without and with transformers
tf0i = find(Ztf==0);
tf1i = find(Ztf~=0);

%% calculate transformer admitance
Ytf = (Ztf~=0).*1./(Ztf+eps.*ones(length(Ztf),1)) + zeros(length(Ztf), 1); 
Gtf = real(Ytf);
Btf = imag(Ytf);


%%----- Vc slack bus iteration -----
%% initialise Jacobian matrix
J         = spalloc(4*ng, 4*ng,14*ng);

%% initialisation
it        = 0;
converged = 0;
cflag     = 0;

%% Newton-Raphson iteration
while ~converged && it<itmax
    %% update iteration counter
    it = it+1;

    %% define cos and sin of angles
    cosfc = cos(Vfa-Vca);
    sinfc = sin(Vfa-Vca);
    cossf = cos(Vsa-Vfa);
    sinsf = sin(Vsa-Vfa);
    cossc = cos(Vsa-Vca);
    sinsc = sin(Vsa-Vca);

    %% converter side power
    Pc  =  Vcm.^2.*Gc  - Vfm.*Vcm.*( Gc.*cosfc  - Bc.*sinfc  );
    Qc  = -Vcm.^2.*Bc  + Vfm.*Vcm.*( Gc.*sinfc  + Bc.*cosfc  );

    %% filter side converter power
    Pcf = -Vfm.^2.*Gc  + Vfm.*Vcm.*( Gc.*cosfc  + Bc.*sinfc  );
    Qcf =  Vfm.^2.*Bc  + Vfm.*Vcm.*( Gc.*sinfc  - Bc.*cosfc  );

    %% filter reactive power
    Qf  = -Bf.*Vfm.^2;

    %% filter side grid power
    Psf =  Vfm.^2.*Gtf - Vfm.*Vsm.*( Gtf.*cossf - Btf.*sinsf );
    Qsf = -Vfm.^2.*Btf + Vfm.*Vsm.*( Gtf.*sinsf + Btf.*cossf );

    %% grid side power
    Ps  = (-Vsm.^2.*Gtf + Vfm.*Vsm.*( Gtf.*cossf + Btf.*sinsf )).*(Ztf~=0) + ...
          (-Vsm.^2.*Gc + Vsm.*Vcm.*( Gc.*cossc + Bc.*sinsc )).*(Ztf==0);
    Qs  = (Vsm.^2.*Btf + Vfm.*Vsm.*( Gtf.*sinsf - Btf.*cossf )).*(Ztf~=0) + ...
          (Vsm.^2.*(Bc+Bf) + Vsm.*Vcm.*( Gc.*sinsc - Bc.*cossc )).*(Ztf==0);

    %% additional filter bus equations
    F1 = Pcf - Psf;
    F2 = Qcf - Qsf - Qf;

    mismatch = [Pcspec-Pc;
                Qsspec-Qs; 
                -F1; 
                -F2];
    mismatch1 = mismatch - [zeros(3*ng,1);mismatch(i4).*(Ztf==0)];
    mismatch1 = mismatch1 -[zeros(2*ng,1);mismatch(i3).*(Ztf==0);zeros(max(ng),1)];
    if max(abs(mismatch1))<tol
        cflag=1;
        break
    end
    %% Jacobian matrix elements    
    J(i1,i1) = diag( -Qc  - Vcm.^2.*Bc ); %% J11
    J(i1,i2) = diag((  Qc  + Vcm.^2.*Bc ).*(Ztf~=0)); %% J12
    J(i1,i3) = diag(  Pc  + Vcm.^2.*Gc ); %% J13
    J(i1,i4) = diag((  Pc  - Vcm.^2.*Gc ).*(Ztf~=0)); %% J14
    
    %% only included without transformer
    J(i2,i1) = diag(( -Ps - Vsm.^2.*Gc      ).*(Ztf==0)); %% J21
    J(i2,i3) = diag((  Qs - Vsm.^2.*(Bc+Bf) ).*(Ztf==0)); %% J23

     %% only included with transformer
    J(i2,i2) = diag(( -Ps  - Vsm.^2.*Gtf ).*(Ztf~=0)); %% J22 
    J(i2,i4) = diag((  Qs  - Vsm.^2.*Btf ).*(Ztf~=0)); %% J24

    J(i3,i1) = diag((  Qcf - Vfm.^2.*Bc             ).*(Ztf~=0));   %% J31
    J(i3,i2) = diag(( -Qcf + Qsf + Vfm.^2.*(Bc+Btf) ).*(Ztf~=0));   %% J32
    J(i3,i3) = diag((  Pcf + Vfm.^2.*Gc             ).*(Ztf~=0));   %% J33
    J(i3,i4) = diag((  Pcf - Psf - Vfm.^2.*(Gc+Gtf) ).*(Ztf~=0));   %% J34

    J(i4,i1) = diag(( -Pcf - Vfm.^2.*Gc                  ).*(Ztf~=0)); %% J41
    J(i4,i2) = diag((  Pcf - Psf + Vfm.^2.*(Gc+Gtf)      ).*(Ztf~=0)); %% J42
    J(i4,i3) = diag((  Qcf - Vfm.^2.*Bc                  ).*(Ztf~=0)); %% J43
    J(i4,i4) = diag((  Qcf - Qsf + Vfm.^2.*(Bc+Btf+2*Bf) ).*(Ztf~=0)); %% J44

    %% remove rows and colums of transformerless buses
    J(i4(tf0i) ,:) = [];
    J(i3(tf0i) ,:) = [];
    J(:, i4(tf0i)) = [];
    J(:, i2(tf0i)) = [];
    mismatch(i4(tf0i),:) = [];
    mismatch(i3(tf0i),:) = [];

    %% calculate correction terms
    corr1 = J\mismatch;
    
    %% add rows to mismatch matrix of transformerless buses
    corr=zeros(4*ng,1);
    corr([i1;i2(tf1i);i3;i4(tf1i)])=corr1;

    %% update converter voltage magnitude and angle
    Vca = Vca + corr(i1);
    Vfa = Vfa + corr(i2);
    Vcm = Vcm.*(ones(ng,1) + corr(i3));
    Vfm = Vfm.*(ones(ng,1) + corr(i4));
end

%% convergence print
if ~cflag
    fprintf(1, '\nSlackbus converter power calculation did NOT converge in %d iterations\n', it);
end

%% define cos and sin of angles
cosfc = cos(Vfa-Vca);
sinfc = sin(Vfa-Vca);
cossf = cos(Vsa-Vfa);
sinsf = sin(Vsa-Vfa);


%%----- Output update -----
%% slack bus VSC grid injection active power
Ps  = (-Vsm.^2.*Gtf + Vfm.*Vsm.*( Gtf.*cossf + Btf.*sinsf )).*(Ztf~=0) + ...
      (-Vsm.^2.*Gc + Vsm.*Vcm.*( Gc.*cossc + Bc.*sinsc )).*(Ztf==0);

%% slack bus converter side reactive power
Qc  = -Vcm.^2.*Bc  + Vfm.*Vcm.*( Gc.*sinfc  + Bc.*cosfc  );

%% slack bus converter voltage
Vc = Vcm.*exp(j*Vca);
return;
    