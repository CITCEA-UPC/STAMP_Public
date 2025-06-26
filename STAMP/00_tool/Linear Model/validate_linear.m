
time = 0:sim_config.Tsample:Tsim_lin;
nSamples = length(time);

time_sim = 0:sim_config.Tsample:sim_config.Tsim;
time_nl  = time_sim - (sim_config.tstep-tstep_lin);
tstep    = sim_config.tstep;

Tinf = 0;
Tsup = Tsim_lin;

if ~newSys
     disp(['For validation, ensure outputs of state-space model match "to_workspace" variables in ' linear])
end

%% Get input/output buses
list_buses = [];
list_DCbuses = [];
list_pqv   = array2table(zeros(0,5),'VariableNames',{'num', 'area' ,'syncarea','bus', 'elementName'});
ports   = [input,output];

for io_idx   = 1:length(ports)
    io_port  = ports{io_idx};

    if ~contains(io_port,'NET.i') && ~contains(io_port,'REF_w')  %line currents, w --> skip
        var_name = split(io_port,'.');
   
        if contains(io_port,'NET.vn') %bus voltages
            list_buses(end+1) = str2double(regexp(var_name{2},'\d*','match'));
        elseif contains(io_port,'DC_NET.v') %bus voltages
            list_DCbuses(end+1) = str2double(regexp(var_name{2},'\d*','match'));
        elseif contains(io_port,'NET.Rl') %load input
            num = regexp(var_name{2},'\d*','match');
            bus = T_load{T_load.number == str2double(num),"bus"};
        else
            num         = regexp(var_name{1},'\d*','match');
            elementName = erase(var_name{1},num);    
            switch elementName
                case 'Load'
                    bus = T_load{T_load.number == str2double(num),"bus"};
                    area = T_load{T_load.number == str2double(num),"Area"};
                    syncarea = T_load{T_load.number == str2double(num),"SyncArea"};
                    list_pqv = [list_pqv; cell2table({str2double(num),area,syncarea,bus,elementName},'VariableNames',{'num','area','syncarea','bus', 'elementName'})]; 
                    list_buses(end+1) = bus;
                case 'Shunt'
                    bus = T_shunt{T_shunt.number == str2double(num),"bus"};
                    area = T_shunt{T_shunt.number == str2double(num),"Area"};
                    syncarea = T_shunt{T_shunt.number == str2double(num),"SyncArea"};
                    list_pqv = [list_pqv; cell2table({str2double(num),area,syncarea,bus,elementName},'VariableNames',{'num','area','syncarea','bus', 'elementName'})]; 
                    list_buses(end+1) = bus;
                case 'TH'
                    bus = T_TH{T_TH.number == str2double(num),"bus"};
                    area = T_TH{T_TH.number == str2double(num),"Area"};
                    syncarea = T_TH{T_TH.number == str2double(num),"SyncArea"};
                    list_pqv = [list_pqv; cell2table({str2double(num),area,syncarea,bus,elementName},'VariableNames',{'num','area','syncarea','bus', 'elementName'})]; 
                    list_buses(end+1) = bus;
                case  'SG'
                    bus = T_SG{T_SG.number == str2double(num),"bus"};
                    area = T_SG{T_SG.number == str2double(num),"Area"};
                    syncarea = T_SG{T_SG.number == str2double(num),"SyncArea"};
                    list_pqv = [list_pqv; cell2table({str2double(num),area,syncarea,bus,elementName},'VariableNames',{'num','area','syncarea', 'bus', 'elementName'})]; 
                    list_buses(end+1) = bus;
                case  'VSC'
                    bus = T_VSC{T_VSC.number == str2double(num),"bus"};
                    area = T_VSC{T_VSC.number == str2double(num),"Area"};
                    syncarea = T_VSC{T_VSC.number == str2double(num),"SyncArea"};
                    list_pqv = [list_pqv; cell2table({str2double(num),area,syncarea,bus,elementName},'VariableNames',{'num','area','syncarea', 'bus', 'elementName'})]; 
                    list_buses(end+1) = bus;
                case  'IPC'
                    bus = T_IPC{T_IPC.number == str2double(num),"bus"};
                    area = T_IPC{T_IPC.number == str2double(num),"Area"};
                    syncarea = T_IPC{T_IPC.number == str2double(num),"SyncArea"};
                    list_pqv = [list_pqv; cell2table({str2double(num),area,syncarea,bus,elementName},'VariableNames',{'num','area','syncarea', 'bus', 'elementName'})]; 
                    list_buses(end+1) = bus;
                case  'USER'
                    bus = T_user{T_user.number == str2double(num),"bus"};
                    area = T_user{T_user.number == str2double(num),"Area"};
                    syncarea = T_user{T_user.number == str2double(num),"SyncArea"};
                    list_pqv = [list_pqv; cell2table({str2double(num),area,syncarea,bus,elementName},'VariableNames',{'num','area','syncarea', 'bus', 'elementName'})]; 
                    list_buses(end+1) = bus;
                case {'REF_w','GFOL','GFOR','STATCOM','WT','Trafo'}
                    % pass
                otherwise
                    T_XX = eval(['T_' elementName]);
                    bus = T_XX{T_XX.number == str2double(num),"bus"};
                    area = T_XX{T_XX.number == str2double(num),"Area"};
                    syncarea = T_XX{T_XX.number == str2double(num),"SyncArea"};
                    list_pqv = [list_pqv; cell2table({str2double(num),area,syncarea,bus,elementName},'VariableNames',{'num','area','syncarea', 'bus', 'elementName'})]; 
                    list_buses(end+1) = bus;
            end                 
        end
    end
end

list_buses  = unique(list_buses);
list_pqv    = unique(list_pqv);

%% DEFINE plot parameters

c1 = [0.4510    0.7922    0.9412];
c2 = [0.1725    0.6078    0.9020];
c3 = [0    0.3647    0.6118];
colors_pi = {c1 c3};

c1 = [0.8000    0.8000    0.8000];
c2 = [0.6510    0.6510    0.6510];
c3 = [0.5020    0.5020    0.5020];
colors_berg = {c1 c3};
colors = [colors_pi(:)' colors_berg(:)'];

gray = {[0.8 0.8 0.8],[0.5020 0.5020 0.5020]};
color_lin   = {[0.2784    0.6275    0.9294],[0    0.4471    0.7412]};
color_nolin = {[0.9294    0.4745    0.2784],[0.8510 0.3255 0.0980]};

pos211 = [0.25 0.6 0.65 0.38];
pos212 = [0.25 0.15  0.65 0.38];

pos221 = [0.15 0.60  0.3 0.38];
pos222 = [0.60 0.60  0.3 0.38];
pos223 = [0.15 0.15  0.3 0.38];
pos224 = [0.60 0.15  0.3 0.38];

pos131 = [0.12 0.23  0.2 0.70];
pos132 = [0.46 0.23  0.2 0.70];
pos133 = [0.78 0.23  0.2 0.70];

pos241 = [0.07 0.60  0.16 0.37];
pos242 = [0.32 0.60  0.16 0.37];
pos243 = [0.57 0.60  0.16 0.37];
pos244 = [0.82 0.60  0.16 0.37];
pos245 = [0.07 0.15  0.16 0.37];
pos246 = [0.32 0.15  0.16 0.37];
pos247 = [0.57 0.15  0.16 0.37];
pos248 = [0.82 0.15  0.16 0.37];

set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

leg_nolin = '';
leg_lin = '';

%% Linear vs non-linear plots

if isempty(list_pqv) % RL NET or no elements. Assume only voltages

    for idx = 1:length(list_buses)

        bus = list_buses(idx);
        % Voltages
        vq_nolin = out_nolin.(['vn' num2str(bus) 'q']);
        vd_nolin = out_nolin.(['vn' num2str(bus) 'd']);
        vdc0   = vq_nolin(find(time_sim>=tstep-0.01,1)); 
        vd0   = vd_nolin(find(time_sim>=tstep-0.01,1)); 
        vq_lin   = out_lin.(['NET_vn' num2str(bus) 'q']) + vdc0*ones(nSamples,1);
        vd_lin   = out_lin.(['NET_vn' num2str(bus) 'd']) + vd0*ones(nSamples,1); 

        f_vi = figure;
    
        figure(f_vi)
            
            ax_uq = subplot(2,1,1);                     
                plot(time_nl,vq_nolin,'LineWidth',1.3,'Color',color_nolin{1})
                hold on
                plot(time,vq_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')
    
                grid on
                xlim([Tinf Tsup])
                set(gcf,'color','w');
                set(gca,'xticklabel',{[]},'FontName','Times New Roman','FontSize',11,'Position',pos211)
                ylabel(['$v_{' num2str(bus) '}^q$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)
                handleLeg = legend(['nolin' leg_nolin],['lin' leg_lin],'Location','best','FontSize',8);
                handleLeg.ItemTokenSize = [15,1];
    
            ax_ud = subplot(2,1,2); 
                plot(time_nl,vd_nolin,'LineWidth',1.3,'Color',color_nolin{1})  
                hold on
                plot(time,vd_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')                      
    
                grid on
                xlim([Tinf Tsup])
                set(gcf,'color','w');
                xlabel('time [s]','Interpreter','latex','FontName','Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',12)
                set(gca,'FontName','Times New Roman','FontSize',11,'Position',pos212)
                ylabel(['$v_{' num2str(bus) '}^d$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)
    end
    for idx = 1:length(list_DCbuses)

        bus = list_DCbuses(idx);
        % Voltages
        vdc_nolin = out_nolin.(['vDC' num2str(bus)]);
        vdc0   = vdc_nolin(find(time_sim>=tstep-0.01,1)); 
        vdc_lin   = out_lin.(['DC_NET_v' num2str(bus) 'DC']) + vdc0*ones(nSamples,1);

        % Currents
        idc_nolin = out_nolin.(['iDC' num2str(bus)]);
        idc0   = idc_nolin(find(time_sim>=tstep-0.01,1));
        idc_lin   = out_lin.(['IPC' num2str(bus) '_iDC']) + idc0*ones(nSamples,1);

        f_dc = figure;

        figure(f_dc)
        %figure   
        ax_vdc = subplot(2,1,1);                     
            plot(time_nl,vdc_nolin,'LineWidth',1.3,'Color',color_nolin{1})
            hold on
            plot(time,vdc_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')

            grid on
            xlim([Tinf Tsup])
            set(gcf,'color','w');
            set(gca,'xticklabel',{[]},'FontName','Times New Roman','FontSize',11,'Position',pos211)
            ylabel(['$vDC_{' num2str(bus) '}$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)
            handleLeg = legend(['nolin' leg_nolin],['lin' leg_lin],'Location','best','FontSize',8);
            handleLeg.ItemTokenSize = [15,1];

        ax_idc = subplot(2,1,2);                     
            plot(time_nl,idc_nolin,'LineWidth',1.3,'Color',color_nolin{1})
            hold on
            plot(time,idc_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')

            grid on
            xlim([Tinf Tsup])
            set(gcf,'color','w');
            set(gca,'FontName','Times New Roman','FontSize',11,'Position',pos212)
            ylabel(['$iDC_{' num2str(bus) '}$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)
            handleLeg = legend(['nolin' leg_nolin],['lin' leg_lin],'Location','best','FontSize',8);
            handleLeg.ItemTokenSize = [15,1];


    end

else % There are loads and/or genenerator elements in the selected buses

    % DC side!
    for idx = 1:length(list_DCbuses)

        bus = list_DCbuses(idx);
        % Voltages
        vdc_nolin = out_nolin.(['vDC' num2str(bus)]);
        vdc0   = vdc_nolin(find(time_sim>=tstep-0.01,1)); 
        vdc_lin   = out_lin.(['DC_NET_v' num2str(bus) 'DC']) + vdc0*ones(nSamples,1);

        % Currents
        idc_nolin = out_nolin.(['iDC' num2str(bus)]);
        idc0   = idc_nolin(find(time_sim>=tstep-0.01,1));
        idc_lin   = out_lin.(['IPC' num2str(bus) '_iDC']) + idc0*ones(nSamples,1);

        f_dc = figure;

        figure(f_dc)
        %figure   
        ax_vdc = subplot(2,1,1);                     
            plot(time_nl,vdc_nolin,'LineWidth',1.3,'Color',color_nolin{1})
            hold on
            plot(time,vdc_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')

            grid on
            xlim([Tinf Tsup])
            set(gcf,'color','w');
            set(gca,'xticklabel',{[]},'FontName','Times New Roman','FontSize',11,'Position',pos211)
            ylabel(['$vDC_{' num2str(bus) '}$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)
            handleLeg = legend(['nolin' leg_nolin],['lin' leg_lin],'Location','best','FontSize',8);
            handleLeg.ItemTokenSize = [15,1];

        ax_idc = subplot(2,1,2);                     
            plot(time_nl,idc_nolin,'LineWidth',1.3,'Color',color_nolin{1})
            hold on
            plot(time,idc_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')

            grid on
            xlim([Tinf Tsup])
            set(gcf,'color','w');
            set(gca,'FontName','Times New Roman','FontSize',11,'Position',pos212)
            ylabel(['$iDC_{' num2str(bus) '}$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)
            handleLeg = legend(['nolin' leg_nolin],['lin' leg_lin],'Location','best','FontSize',8);
            handleLeg.ItemTokenSize = [15,1];

     end

    for idx = 1:height(list_pqv)

        num = list_pqv.num(idx);
        bus = list_pqv.bus(idx);
        area = list_pqv.area(idx);
        syncarea = list_pqv.syncarea(idx);
        elementName = list_pqv.elementName{idx};

       % Voltages
       vq_nolin = out_nolin.(['vn' num2str(bus) 'q']);
       vd_nolin = out_nolin.(['vn' num2str(bus) 'd']);
       vdc0   = vq_nolin(find(time_sim>=tstep-0.01,1)); 
       vd0   = vd_nolin(find(time_sim>=tstep-0.01,1)); 
       vq_lin   = out_lin.(['NET_vn' num2str(bus) 'q']) + vdc0*ones(nSamples,1);
       vd_lin   = out_lin.(['NET_vn' num2str(bus) 'd']) + vd0*ones(nSamples,1); 


       % Currents
       k=1;
       if elementName == "Load" || elementName =="Shunt"
           k = -1;
       end

       iq_nolin = out_nolin.(['I_' elementName num2str(num) '_q']);
       id_nolin = out_nolin.(['I_' elementName num2str(num) '_d']);
       iq0   = iq_nolin(find(time_sim>=tstep-0.01,1)); 
       id0   = id_nolin(find(time_sim>=tstep-0.01,1)); 
       if elementName == "IPC"
            iq_lin   = k*out_lin.([elementName num2str(num) '_idiffq']) + iq0*ones(nSamples,1);
            id_lin   = k*out_lin.([elementName num2str(num) '_idiffd']) + id0*ones(nSamples,1);
       else
           iq_lin   = k*out_lin.([elementName num2str(num) '_iq']) + iq0*ones(nSamples,1);
           id_lin   = k*out_lin.([elementName num2str(num) '_id']) + id0*ones(nSamples,1);
       end

        f_vi = figure;

        figure(f_vi)

            ax_uq = subplot(2,2,1);                     
                plot(time_nl,vq_nolin,'LineWidth',1.3,'Color',color_nolin{1})
                hold on
                plot(time,vq_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')

                grid on
                xlim([Tinf Tsup])
                set(gcf,'color','w');
                set(gca,'xticklabel',{[]},'FontName','Times New Roman','FontSize',11,'Position',pos221)
                ylabel(['$v_{' num2str(bus) '}^q$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)
                handleLeg = legend(['nolin' leg_nolin],['lin' leg_lin],'Location','best','FontSize',8);
                handleLeg.ItemTokenSize = [15,1];

            ax_ud = subplot(2,2,3); 
                plot(time_nl,vd_nolin,'LineWidth',1.3,'Color',color_nolin{1})  
                hold on
                plot(time,vd_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')                      

                grid on
                xlim([Tinf Tsup])
                set(gcf,'color','w');
                xlabel('time [s]','Interpreter','latex','FontName','Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',12)
                set(gca,'FontName','Times New Roman','FontSize',11,'Position',pos223)
                ylabel(['$v_{' num2str(bus) '}^d$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)


            ax_iq = subplot(2,2,2); 
                plot(time_nl,iq_nolin,'LineWidth',1.3,'Color',color_nolin{1})
                hold on
                plot(time,iq_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')

                grid on
                xlim([Tinf Tsup])
                set(gcf,'color','w');
                set(gca,'xticklabel',{[]},'FontName','Times New Roman','FontSize',11,'Position',pos222)
                ylabel(['$i_{' elementName num2str(bus) '}^q$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)

            ax_id = subplot(2,2,4); 
                plot(time_nl,id_nolin,'LineWidth',1.3,'Color',color_nolin{1})
                hold on
                plot(time,id_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')

                grid on
                xlim([Tinf Tsup])
                set(gcf,'color','w');
                xlabel('time [s]','Interpreter','latex','FontName','Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
                set(gca,'FontName','Times New Roman','FontSize',11,'Position',pos224)
                ylabel(['$i_{' elementName num2str(bus) '}^d$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)

                set(gcf,'Position',[100 100 540 300])
              
       P_nolin = 3/2.*(vq_nolin.*iq_nolin + vd_nolin.*id_nolin);
       Q_nolin = 3/2.*(vq_nolin.*id_nolin - vd_nolin.*iq_nolin);
       P_lin = 3/2.*(vq_lin.*iq_lin + vd_lin.*id_lin);
       Q_lin = 3/2.*(vq_lin.*id_lin - vd_lin.*iq_lin);

       f_pq = figure;

       figure(f_pq)

            ax_uq = subplot(2,1,1);                     
                plot(time_nl,P_nolin,'LineWidth',1.3,'Color',color_nolin{1})
                hold on
                plot(time,P_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')

                grid on
                xlim([Tinf Tsup])
                set(gcf,'color','w');
                set(gca,'xticklabel',{[]},'FontName','Times New Roman','FontSize',11,'Position',pos211)
                ylabel(['$P_{' elementName num2str(bus) '}$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)
                handleLeg = legend(['nolin' leg_nolin],['lin' leg_lin],'Location','best','FontSize',8);
                handleLeg.ItemTokenSize = [15,1];

            ax_ud = subplot(2,1,2); 
                plot(time_nl,Q_nolin,'LineWidth',1.3,'Color',color_nolin{1})  
                hold on
                plot(time,Q_lin,'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')                       

                grid on
                xlim([Tinf Tsup])
                set(gcf,'color','w');
                xlabel('time [s]','Interpreter','latex','FontName','Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',12)
                set(gca,'FontName','Times New Roman','FontSize',11,'Position',pos212)
                ylabel(['$Q_{' elementName num2str(bus) '}$ [pu]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)

        if elementName ~= "Load" && elementName ~= "Shunt" && elementName ~= "TH" && elementName ~= "USER"

            switch elementName
                case 'VSC'
                    elementName = T_VSC{T_VSC.number == num, "mode"}{:};
            end


           f_w = figure;
           figure(f_w)  
               w_nolin  = out_nolin.([elementName num2str(num) '_w']);      %out_nolin.w_SG1;
               w0       = w_nolin(find(time_sim>=tstep-0.01,1));  
               if num==num_slk(area) && convertCharsToStrings(elementName) == convertCharsToStrings(element_slk{area})
                   w_lin    = out_lin.([REF_w num2str(syncarea)]) + w0; % slack !!!!!!!!
               else
                   w_lin    = out_lin.([elementName num2str(num) '_w']) + w0;
               end
               ax_w = subplot(1,1,1);                 
                    plot(time_nl,w_nolin/(2*pi),'LineWidth',1.3,'Color',color_nolin{1})
                    hold on
                    plot(time,w_lin/(2*pi),'LineWidth',1.3,'Color',color_lin{1},'LineStyle','--')

                    grid on
                    xlim([Tinf Tsup])
                    set(gcf,'color','w');
                    set(gca,'FontName','Times New Roman','FontSize',11)
                    xlabel('time [s]','Interpreter','latex','FontName','Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',12)
                    ylabel(['$f_{' elementName num2str(bus) '}$ [Hz]'],'Interpreter','latex','FontAngle','normal','FontWeight','bold','FontSize',12)
                    handleLeg = legend(['nolin' leg_nolin],['lin' leg_lin],'Location','best','FontSize',8);
                    handleLeg.ItemTokenSize = [15,1];       
            set(gcf,'Position',[100 100 670 340/1.7])
            %exportgraphics(f_w,[path_results id_case '_freq_bus' num2str(nbus_real) '.emf'])
            %exportgraphics(f_w,[path_results id_case '_freq_bus' num2str(nbus_real) '.eps'])
        end
    end
end