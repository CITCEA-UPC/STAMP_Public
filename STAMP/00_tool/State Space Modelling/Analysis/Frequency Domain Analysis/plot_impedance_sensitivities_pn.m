function plot_impedance_sensitivities_pn(ss,factorArray,FSUP,STEP,transfer_function_type, plot_only_pp,scale)
   
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

        %% Positive negative sequence:
        Az = 1/sqrt(2)*[1 -1i ; 1 1i];
        Az_inv = 1/sqrt(2)*[1 1 ; 1i -1i];
        for w=1:1:size(karray,2)
            
            GRID_matrix(:,:,w) = GRID_matrix(:,:,w)/scale;
            %Magnitude
            GRID_matrix_pn(:,:,w) =Az*GRID_matrix(:,:,w)*Az_inv;
            abspp{w,control} = abs(GRID_matrix_pn(1,1,w));
            abspn{w,control} = abs(GRID_matrix_pn(1,2,w));
            absnp{w,control} = abs(GRID_matrix_pn(2,1,w));
            absnn{w,control} = abs(GRID_matrix_pn(2,2,w));
            %Phase
            anglepp{w,control} = angle(GRID_matrix_pn(1,1,w));
            anglepn{w,control} = angle(GRID_matrix_pn(1,2,w));
            anglenp{w,control} = angle(GRID_matrix_pn(2,1,w));
            anglenn{w,control} = angle(GRID_matrix_pn(2,2,w));
        end
    
    end

    set(groot,'defaultAxesTickLabelInterpreter','latex');  

    figure
    %('visible','on','Units','centimeters','Position',[4 4 4 8]);
    tiledlayout(4,2,"TileSpacing","compact")
    
    %%% plot magnitude pp

    nexttile
    grid on
    hold on

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[abspp{:,control}],'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$|Y_{pp}|$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$|Z_{pp}|$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])

    %%% plot magnitude pn 

    nexttile
    grid on
    hold on
    
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[abspn{:,control}],'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$|Y_{pn}|$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$|Z_{pn}|$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])

    %%% plot angle pp

    nexttile
    grid on
    hold on  

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[anglepp{:,control}]*180/pi,'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$\theta_{Y_{pp}}$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$\theta_{Z_{pp}}$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')

    %%% plot angle pn

    nexttile
    grid on
    hold on    

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[anglepn{:,control}]*180/pi,'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$\theta_{Y_{pn}}$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$\theta_{Z_{pn}}$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')

    %%% plot magnitude np

    nexttile
    grid on
    hold on

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[absnp{:,control}],'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$|Y_{np}|$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$|Z_{np}|$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])

    %%% plot magnitude nn

    nexttile
    grid on
    hold on  

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[absnn{:,control}],'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$|Y_{nn}|$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$|Z_{nn}|$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])

    %%% plot angle np

    nexttile
    grid on
    hold on  

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[anglenp{:,control}]*180/pi,'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

    if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$\theta_{Y_{np}}$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$\theta_{Z_{np}}$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')

    %%% plot angle nn

    nexttile
    grid on
    hold on

    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[anglenn{:,control}]*180/pi,'Color',COLORiter(control,:))
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

     if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
        ylabel('$\theta_{Y_{nn}}$','Interpreter','Latex')
    elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
        ylabel('$\theta_{Z_{nn}}$','Interpreter','Latex')
    end
    xlabel('f [Hz]','Interpreter','Latex')
    set(gca,'FontName','Times','FontSize',8)

    %%% Set legend/colorbar

    colormap(COLORiter);
    hc = colorbar;
    set(hc,'Ticks',linspace(0,1,length(factorArray)),'YTickLabel',factorArray,'FontSize',8,'FontName','Times')
    title('','Interpreter','latex','Fontsize',8)        
    hold on

    %%% Optionally plot just positive sequence

    if plot_only_pp == 1
        figure('visible','on','Units','centimeters','Position',[4 4 40 20]);
        tiledlayout(2,1,"TileSpacing","compact")
        
        nexttile
        hold on
        grid on

        for control=1:1:size(ss,2)
            plot(karray/(2*pi),[abspp{:,control}],'Color',COLORiter(control,:))
        end
        plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])


        if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
            ylabel('$|Y_{pp}|$','Interpreter','Latex')
        elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
            ylabel('$|Z_{pp}|$','Interpreter','Latex')
        end
        xlabel('f [Hz]','Interpreter','Latex','FontSize',12)
        ylim([0 ylimit])
        set(gca,'FontName','Times','FontSize',12)

        nexttile
        hold on
        grid on

        for control=1:1:size(ss,2)
            plot(karray/(2*pi),[anglepp{:,control}]*180/pi,'Color',COLORiter(control,:))
        end
        plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
        plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])

        if (strcmp(transfer_function_type,'Admittance')||strcmp(transfer_function_type,'admittance'))
            ylabel('$\theta_{Y_{pp}}$','Interpreter','Latex')
        elseif (strcmp(transfer_function_type,'Impedance')||strcmp(transfer_function_type,'impedance'))
            ylabel('$\theta_{Z_{pp}}$','Interpreter','Latex')
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