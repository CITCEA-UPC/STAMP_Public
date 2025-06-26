function plot_passivity_sensitivities(ss,factorArray,FSUP,STEP,scale)
    
    figure
    hold on
    COLORiter=(linspace(0,0.9,length(factorArray))').*[1 1 1];
    
    if size(ss,2)==1
        COLORiter(1,:)=[0 0 0];
    end
    for control=1:1:size(ss,2)
        ss_control = ss{control};

        FINF = 0;

        SAMPLES = ceil((FSUP-FINF)/STEP)+1;                                                  % 1 EIG per 1 Hz             
        karray  = linspace(FINF,FSUP,SAMPLES)*2*pi; 
      
        s       = 1i*karray;

        [GRID_matrix] = freqresp(ss_control,s);

        for w=1:1:size(karray,2)

            GRID_matrix(:,:,w) = GRID_matrix(:,:,w)/scale;
            
            F = 0.5.*(GRID_matrix(:,:,w) + GRID_matrix(:,:,w)');
            alphamin2(w,control)         = min(eig(F));
        end
          
        plot(karray/(2*pi),alphamin2(:,control),'Color',COLORiter(control,:))
        hold on  
    end

    
    set(groot,'defaultAxesTickLabelInterpreter','latex');  

    % Plot straight line at y=1
    plot(karray/(2*pi),zeros(size(karray,2)),'Color',[0.8500 0.3250 0.0980],'LineStyle','--')
    
    colormap(COLORiter);
    hc = colorbar;
    set(hc,'Ticks',linspace(0,1,length(factorArray)),'YTickLabel',factorArray,'FontSize',8,'FontName','Times')
    title('','Interpreter','latex','Fontsize',10)        
    grid on
    hold on
    
    hold off
    ylabel('$\lambda_{min}$','Interpreter','Latex','FontSize',8)
    xlabel('f [Hz]','Interpreter','Latex','FontSize',8)
    set(gca,'fontname','times','fontsize',8)
    %ylim([-2 15])
    %xlim([0 3e3])

end