function FIGURE_SENSITIVITY_1ZY(ss,factorArray)
    ylimit=1.5;
    COLORiter=(linspace(0,0.9,length(factorArray))').*[1 1 1];
    
    if size(ss,2)==1
        COLORiter(1,:)=[0 0 0];
    end
    for control=1:1:size(ss,2)
        ss_control = ss{control};
        syms s
        FSUP = 4e3;
        FINF = 0;
        STEP = 1;
        n      = 0;
        SAMPLES = ceil((FSUP-FINF)/STEP)+1;                                                  % 1 EIG per 1 Hz             
        karray  = linspace(FINF,FSUP,SAMPLES)*2*pi(); 
      
        s       = 1i*karray;

        [GRID_matrix] = freqresp(ss_control,s);

        %% Positive negative sequence:
        Az = 1/sqrt(2)*[1 -1i ; 1 1i];
        Az_inv = 1/sqrt(2)*[1 1 ; 1i -1i];
        for w=1:1:size(karray,2)
            %Magnitude
            GRID_matrix_pn(:,:,w) = Az*GRID_matrix(:,:,w)*Az_inv;
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

    figure('visible','on','Units','centimeters','Position',[4 4 4 8]);
    tiledlayout(4,2,"TileSpacing","compact")
    nexttile
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[abspp{:,control}],'Color',COLORiter(control,:))
        hold on
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold off
    ylabel('$|Y_{pp}|$','Interpreter','Latex')
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])
    nexttile
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[abspn{:,control}],'Color',COLORiter(control,:))
        hold on
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold off
    ylabel('$|Y_{pn}|$','Interpreter','Latex')
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])
    nexttile
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[anglepp{:,control}]*180/pi,'Color',COLORiter(control,:))
        hold on
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold on
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold off
    ylabel('$\theta_{Y_{pp}}$','Interpreter','Latex')
    xlabel('f [Hz]','Interpreter','Latex')
    nexttile
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[anglepn{:,control}]*180/pi,'Color',COLORiter(control,:))
        hold on
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold on
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold off
    ylabel('$\theta_{Y_{pn}}$','Interpreter','Latex')
    xlabel('f [Hz]','Interpreter','Latex')
    nexttile
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[absnp{:,control}],'Color',COLORiter(control,:))
        hold on
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold off
    ylabel('$|Y_{np}|$','Interpreter','Latex')
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])
    nexttile
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[absnn{:,control}],'Color',COLORiter(control,:))
        hold on
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*1,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold off
    ylabel('$|Y_{nn}|$','Interpreter','Latex')
    xlabel('f [Hz]','Interpreter','Latex')
    ylim([0 ylimit])
    nexttile
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[anglenp{:,control}]*180/pi,'Color',COLORiter(control,:))
        hold on
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold on
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold off
    ylabel('$\theta_{Y_{np}}$','Interpreter','Latex')
    xlabel('f [Hz]','Interpreter','Latex')
    nexttile
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[anglenn{:,control}]*180/pi,'Color',COLORiter(control,:))
        hold on
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold on
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold off
    ylabel('$\theta_{Y_{nn}}$','Interpreter','Latex')
    xlabel('f [Hz]','Interpreter','Latex')
    set(gca,'FontName','Times','FontSize',8)





    figure('visible','on','Units','centimeters','Position',[4 4 4 8]);
    tiledlayout(2,1,"TileSpacing","compact")
    nexttile
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[abspp{:,control}],'Color',COLORiter(control,:))
        hold on
    end
    hold off
    grid on
    ylabel('$|Y_{pp}|$','Interpreter','Latex','FontSize',8)
    xlabel('f [Hz]','Interpreter','Latex','FontSize',8)
    %ylim([0 ylimit])
    set(gca,'FontName','Times','FontSize',8)
    nexttile
    for control=1:1:size(ss,2)
        plot(karray/(2*pi),[anglepp{:,control}]*180/pi,'Color',COLORiter(control,:))
        hold on
    end
    plot(karray/(2*pi),ones(1,size(karray,2))*90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold on
    plot(karray/(2*pi),ones(1,size(karray,2))*-90,'LineStyle','--','Color',[0.8500 0.3250 0.0980])
    hold off
    grid on
    ylabel('$\theta_{Y_{pp}} [^{\circ}]$','Interpreter','Latex','FontSize',8)
    yticks([-90 90])
    xlabel('f [Hz]','Interpreter','Latex','FontSize',8)
    set(gca,'FontName','Times','FontSize',8)
end