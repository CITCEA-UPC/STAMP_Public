%% Calculate R,X loads in case of PQ loads

for idx = 1:height(T_load)

    bus = T_load{idx,"bus"};
    T_load.V(idx)     = results.bus{results.bus.bus == bus,"Vm"};
    T.load.theta(idx) = results.bus{results.bus.bus == bus,"theta"};
    num = T_load{idx,"number"};

    if T_load.type(idx) == "PQ" %Calculate equivalent RX        
        %T_load.R(idx) = abs(1/results.load{results.load.bus == bus,"P"});
        %T_load.X(idx) = abs(1/results.load{results.load.bus == bus,"Q"});
        T_load.R(idx) = abs(results.bus.Vm(results.bus.bus==bus)^2/results.load{results.load.bus == bus & results.load.number == num,"P"});
        T_load.X(idx) = results.bus.Vm(results.bus.bus==bus)^2/results.load{results.load.bus == bus & results.load.number == num,"Q"};
        if isinf(T_load.X(idx))
            T_load.X(idx) = 0;
        end
    elseif T_load.type(idx) == "RX" %Calculate equivalent PQ
        T_load.P(idx) = results.bus.Vm(results.bus.bus==bus)^2/T_load.R(idx);
        T_load.Q(idx) = results.bus.Vm(results.bus.bus==bus)^2/T_load.X(idx);
        if isinf(T_load.Q(idx))
            T_load.Q(idx) = 0;
        end        
    end
end

%% Write power-flow data to T_PF

T_PF.Vm = results.bus.Vm;
T_PF.theta = results.bus.theta;

%% Write power-flow data to generator elements tables 

T_TH   = PF2table(T_TH, results.bus, results.th);
T_SG   = PF2table(T_SG, results.bus, results.sg);
T_VSC  = PF2table(T_VSC, results.bus, results.vsc);
if fanals==3
    T_IPC  = PFdc2table(T_IPC, results.bus,results_dc.busdc);
end
T_user = PF2table(T_user, results.bus, results.user);

% MMC, b2b --> to be added

%% Compute penetration of generator elements

% In case thar many generator elements are connected to same bus, define the
% penetration (proportion of P,Q from power-flow) that corresponds to each
% element.
    % alfa: penetration of VSC
    % beta: share of GFOL in VSC penetration

    if shared_power == 1
        disp("In 'update_OP.m' T_CASE will be used to determine PQ share between SG and VSC in same bus")
        T_case          = readtable(excel,'Sheet','CASE');      
        for idx = 1:height(T_case)
            bus = T_case.bus(idx);
            if T_case.SG(idx) ~= 0
                T_SG.P(T_SG.bus == bus)  = T_SG.P(T_SG.bus == bus)*T_case.SG(idx);
                T_SG.Q(T_SG.bus == bus)  = T_SG.Q(T_SG.bus == bus)*T_case.SG(idx);
                T_SG.Sn(T_SG.bus == bus) = T_SG.Sn(T_SG.bus == bus)*T_case.SG(idx); %re-scale device
            end
            if T_case.GFOR(idx) ~= 0
                T_VSC.P(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOR'))  = T_VSC.P(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOR'))*T_case.GFOR(idx);
                T_VSC.Q(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOR'))  = T_VSC.Q(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOR'))*T_case.GFOR(idx);
                T_VSC.Sn(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOR')) = T_VSC.Sn(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOR'))*T_case.GFOR(idx); %re-scale device
            end
            if T_case.GFOL(idx) ~= 0
                T_VSC.P(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOL'))  = T_VSC.P(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOL'))*T_case.GFOL(idx);
                T_VSC.Q(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOL'))  = T_VSC.Q(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOL'))*T_case.GFOL(idx);
                T_VSC.Sn(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOL')) = T_VSC.Sn(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOL'))*T_case.GFOL(idx); %re-scale device
            end
        end
    end