function plot_impedance_sensitivities_qd(ss,factorArray,FSUP,STEP,transfer_function_type, plot_only_qq,scale)
   
    ylimit=10;
    COLORiter=(linspace(0,0.9,length(factorArray))').*[1 1 1];
    
    if size(ss,2)==1
        COLORiter(1,:)=[0 0 0];
    end
    for control=1:1:size(ss,2)
        ss_control = ss{control};

        FINF = 0;

        SAMPLES = ceil((FSUP-FINF)/STEP)+1;                                                  % 1 EIG per 1 Hz             
        karray  = linspace(FINF,FSUP,SAMPLES)*2*pi(); 
      
        s       = 1i*karray;

        [GRID_matrix] = freqresp(ss_control,s);
        
        for w=1:1:size(karray,2)

            GRID_matrix(:,:,w) = GRID_matrix(:,:,w)/scale;
            %Magnitude
            absqq{w,control} = abs(GRID_matrix(1,1,w));
            absqd{w,control} = abs(GRID_matrix(1,2,w));
            absdq{w,control} = abs(GRID_matrix(2,1,w));
            absdd{w,control} = abs(GRID_matrix(2,2,w));
            %Phase
            angleqq{w,control} = angle(GRID_matrix(1,1,w));
            angleqd{w,control} = angle(GRID_matrix(1,2,w));
            angledq{w,control} = angle(GRID_matrix(2,1,w));
            angledd{w,control} = angle(GRID_matrix(2,2,w));
        end
    
    end

    set(groot,'defaultAxesTickLabelInterpreter','latex');  

    figure
    %('visible','on','Units','centimeters','Position',[4 4 4 8]);
    tiledlayout(4,2,"TileSpacing","compact")
    
    %%% plot magnitude qq

    nexttile
    grid on
    hold on
    
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[absqq{:,control}],'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$|Y_{qq}|$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$|Z_{qq}|$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])

    %%% plot magnitude qd 

    nexttile
    grid on
    hold on   

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[absqd{:,control}],'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$|Y_{qd}|$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$|Z_{qd}|$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])

    %%% plot angle qq

    nexttile
    grid on
    hold on

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[angleqq{:,control}]*180/pi,'Color',COLORiter(control,:))
        hold on
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$\theta_{Y_{qq}}$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$\theta_{Z_{qq}}$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')

    %%% plot angle qd

    nexttile
    grid on
    hold on

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[angleqd{:,control}]*180/pi,'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$\theta_{Y_{qd}}$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$\theta_{Z_{qd}}$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')

    %%% plot magnitude dq

    nexttile
    grid on
    hold on

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[absdq{:,control}],'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$|Y_{dq}|$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$|Z_{dq}|$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])

    %%% plot magnitude dd

    nexttile
    grid on
    hold on

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[absdd{:,control}],'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$|Y_{dd}|$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$|Z_{dd}|$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])

    %%% plot angle dq

    nexttile
    grid on
    hold on

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[angledq{:,control}]*180/pi,'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$\theta_{Y_{dq}}$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$\theta_{Z_{dq}}$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')

    %%% plot angle dd

    nexttile
    grid on
    hold on

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[angledd{:,control}]*180/pi,'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

     if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$\theta_{Y_{dd}}$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$\theta_{Z_{dd}}$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')
    set(gca,'FontName','Times','FontSize',8)

    %%% Set legend/colorbar

    colormap(COLORiter);
    hc = colorbar;
    set(hc,'Ticks',linspace(0,1,length(factorArray)),'YTickLabel',factorArray,'FontSize',8,'FontName','Times')
    title('','Interpreter','latex','Fontsize',10)        
    grid on
    hold on

    %%% Optionally plot just positive sequence

    if plot_only_qq == 1
        figure('visible','on','Units','centimeters','Position',[4 4 40 20]);
        tiledlayout(2,1,"TileSpacing","compact")

        nexttile
        hold on
        grid on

        for control=1:1:size(ss,2)
            plot(karray/(2*pi),[absqq{:,control}],'Color',COLORiter(control,:))
        end
        plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
        
        if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$|Y_{qq}|$','Interpreter','Latex')
        elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$|Z_{qq}|$','Interpreter','Latex')
        end
        
        xlabel('f [Hz]','Interpreter','Latex','FontSize',12)
        ylim([0 ylimit])
        set(gca,'FontName','Times','FontSize',12)

        nexttile
        hold on
        grid on

        for control=1:1:size(ss,2)
            plot(karray/(2*pi),[angleqq{:,control}]*180/pi,'Color',COLORiter(control,:))
        end
        plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
        plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

        if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
            ylabel('$\theta_{Y_{qq}}$','Interpreter','Latex')
        elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
            ylabel('$\theta_{Z_{qq}}$','Interpreter','Latex')
        end

        %yticks([-90 90])
        xlabel('f [Hz]','Interpreter','Latex','FontSize',12)
        set(gca,'FontName','Times','FontSize',12)
    
        colormap(COLORiter);
        hc = colorbar;
        set(hc,'Ticks',linspace(0,1,length(factorArray)),'YTickLabel',factorArray,'FontSize',12,'FontName','Times')
        title('','Interpreter','latex','Fontsize',12)        
        
    end
end