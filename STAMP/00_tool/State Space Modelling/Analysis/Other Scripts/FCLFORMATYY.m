    pos21  = [0.15 0.575 0.775 0.4];
    pos22  = [0.15 0.15 0.775 0.4]; 
    pos1   = [0.15 0.15 0.70 0.70];
    
    set(groot,'defaultAxesTickLabelInterpreter','latex');  
    set(groot,'defaulttextinterpreter','latex');
    set(groot,'defaultLegendInterpreter','latex');
    
    for num=1:1:nl %    Number of EIGs
        eval(sprintf('LAMBDAN = lambda%d;',num))       
        
        FCLPLOT(LAMBDAN,fr,nl,OPTION2,NSUB,num);
           
    end    
    
    switch OPTION2
        
        case 'MAGREAL'
            
            subplot(2,1,1);
            set(gca,'xticklabel',{[]},'XGrid','on','FontName','Times New Roman','FontSize',12,'Position',pos21);
            ylabel('Magnitude','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            %legend(legendname,'FontName','Times New Roman','FontSize',12);
            
            subplot(2,1,2);
            set(gca,'XGrid','on','FontName','Times New Roman','FontSize',12,'Position',pos22);
            xlabel('frequency [Hz]','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            ylabel('Real part','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            plot([FINF,FSUP],[0,0],'--','LineWidth',1,'Color',[0.7 0.7 0.7])
            %legend(legendname,'FontName','Times New Roman','FontSize',12);
            
        case 'MAGPH'
            
            subplot(2,1,1);
            set(gca,'xticklabel',{[]},'XGrid','on','FontName','Times New Roman','FontSize',12,'Position',pos21);
            ylabel('Magnitude','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            %legend(legendname,'FontName','Times New Roman','FontSize',12);
            
            subplot(2,1,2);
            set(gca,'XGrid','on','FontName','Times New Roman','FontSize',12,'Position',pos22);
            xlabel('frequency [Hz]','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            ylabel('Phase [degrees]','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            plot([FINF,FSUP],[180,180],'--','LineWidth',1,'Color',[0.7 0.7 0.7])
            plot([FINF,FSUP],[0,0],'--','LineWidth',1,'Color',[0.7 0.7 0.7])
            plot([FINF,FSUP],[-180,-180],'--','LineWidth',1,'Color',[0.7 0.7 0.7])
            %legend(legendname,'FontName','Times New Roman','FontSize',12);
        
        case 'BODE'
            
            subplot(2,1,1);
            set(gca,'XScale','log','xticklabel',{[]},'XGrid','on','FontName','Times New Roman','FontSize',12,'Position',pos21);
            ylabel('Magnitude [dB]','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            %legend(legendname,'FontName','Times New Roman','FontSize',12);
            
            subplot(2,1,2);
            set(gca,'XScale','log','XGrid','on','FontName','Times New Roman','FontSize',12,'Position',pos22);
            xlabel('frequency [Hz]','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            ylabel('Phase [degrees]','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            plot([FINF,FSUP],[180,180],'--','LineWidth',1,'Color',[0.7 0.7 0.7])
            plot([FINF,FSUP],[0,0],'--','LineWidth',1,'Color',[0.7 0.7 0.7])
            plot([FINF,FSUP],[-180,-180],'--','LineWidth',1,'Color',[0.7 0.7 0.7])
            %legend(legendname,'FontName','Times New Roman','FontSize',12);
            
        case 'MAG'
            
            subplot(NSUB,1,1);
            set(gca,'XGrid','on','FontName','Times New Roman','FontSize',12);
            xlabel('frequency [Hz]','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            ylabel('Magnitude','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            %legend(legendname,'FontName','Times New Roman','FontSize',12);
            
        case 'REAL'
            
            subplot(NSUB,1,NSUB);
            set(gca,'XGrid','on','FontName','Times New Roman','FontSize',12);
            xlabel('frequency [Hz]','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            ylabel('Real part','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            plot([FINF,FSUP],[0,0],'--','LineWidth',1,'Color',[0.7 0.7 0.7])
            %legend(legendname,'FontName','Times New Roman','FontSize',12); 
            
        case 'IMAG'
            
            subplot(NSUB,1,NSUB);
            set(gca,'XGrid','on','FontName','Times New Roman','FontSize',12);
            xlabel('frequency [Hz]','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            ylabel('Imaginary part','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            plot([FINF,FSUP],[0,0],'--','LineWidth',1,'Color',[0.7 0.7 0.7])
            %legend(legendname,'FontName','Times New Roman','FontSize',12);
            
        case 'PASS'

            subplot(2,1,1);
            plot(fr,Lmin_z,'LineWidth',2)
            hold on
            plot(fr,Lmin_y,'LineWidth',2)
            set(gca,'XScale','log','xticklabel',{[]},'XGrid','on','FontName','Times New Roman','FontSize',12,'Position',pos21);
            ylabel('$\lambda_{min}$','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            plot([FINF,FSUP],[0,0],'--','LineWidth',1,'Color',[0.7 0.7 0.7])

            %legend(legendname,'FontName','Times New Roman','FontSize',12);

            subplot(2,1,2);
            stairs(fr,issemiposdef_z,'LineWidth',2)
            hold on
            stairs(fr,issemiposdef_y,'LineWidth',2)
            set(gca,'XScale','log','XGrid','on','FontName','Times New Roman','FontSize',12,'Position',pos22);
            xlabel('frequency [Hz]','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            ylabel('$\lambda_{min}$ flag','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            %legend(legendname,'FontName','Times New Roman','FontSize',12);
            set(gca,'YTick',[0 1],'YTickLabel',[0 1]);
        case 'NYQ'
            
            subplot(NSUB,1,NSUB);
            set(gca,'XScale','linear','FontName','Times New Roman','FontSize',11,'Position',pos1);
            xlabel('Real axis','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
            ylabel('Imaginary axis','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11) 
            hold on
            axis equal
            %grid on
            
            %   UNIT CIRCLE
            
            x   = 0;
            y   = 0;
            ang = 0:0.01:2*pi; 
            xp  = 1*cos(ang);
            yp  = 1*sin(ang);
            plot(x+xp,y+yp,':','LineWidth',1.5,'Color',[0.7 0.7 0.7]);
    
            %   YLINE
    
            plot(xlim(),[0,0],'--','LineWidth',1,'Color',[0.7 0.7 0.7]);
    
            %   XLINE
    
            plot([-1,-1],ylim(),'--','LineWidth',1,'Color',[0.7 0.7 0.7]);
    
            %   ORIGIN MARKER
    
            plot(0,0,'+','MarkerSize',15,'LineWidth',2,'Color',[0 0 0]);
            
    end
    
%%  LEGEND 
 
switch OPTION2
    case 'PASS'
        
        legend({'$Z$' '$Y$'})
        
    otherwise  
        
        for num=1:1:nl %    Number of EIGs 
%             name=strcat('$','Y_{',sprintf('%d',num),'}$'); 
            name=strcat('$','\lambda_{',sprintf('%d',num),'}$'); 
            eval(sprintf('legendname{%d}=name;',num))       
        end
        legend(legendname,'FontName','Times New Roman','FontSize',12); 
end