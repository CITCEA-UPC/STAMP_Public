function get_sensitivy_eigenvalues_figure(list_KEPCO_ss,factorArray)
    %factorArray = [0.1:0.1:1 2:1:8];               %0.1 to 10
    % Plotting parameters
    COLORiter=(linspace(0,0.9,length(factorArray))').*[1 1 1];

    % Figure eigenvalues
    fig=figure('visible','on','Units','centimeters','Position',[2 2 15 8]);
        for control = 1:1:size(list_KEPCO_ss,2)
            T_EIG = eig(list_KEPCO_ss{control}.A);
            scatter(real(T_EIG), imag(T_EIG),'MarkerFaceColor',COLORiter(control,:),'MarkerEdgeColor',COLORiter(control,:))
            set(gca,'TickLabelInterpreter','latex')
            xlabel('$\Re(\lambda)$','Interpreter','latex','FontSize',8)
            ylabel('$\Im(\lambda)$','Interpreter','latex','FontSize',8)
            colormap(COLORiter);
            hc = colorbar;
            set(hc,'Ticks',linspace(0,1,length(factorArray)),'YTickLabel',factorArray,'FontSize',8,'FontName','Times')
            title('','Interpreter','latex','Fontsize',10)        
            grid on
            hold on
        end 
        hold off
        xlabel('$\Re(\lambda)$','Interpreter','latex','FontSize',8)
        ylabel('$\Im(\lambda)$','Interpreter','latex','FontSize',8)
        ylim([-1.5e4 1.5e4])
        xlim([-300 60])
     %saveas(fig,'tau.pdf')
    
end