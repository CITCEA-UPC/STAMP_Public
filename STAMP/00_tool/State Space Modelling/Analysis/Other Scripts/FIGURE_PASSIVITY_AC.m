function FIGURE_PASSIVITY_AC(GRID_MATRIX_PN,factorarray)
%%
Yb=1;
COLORiter=(linspace(0,0.9,length(factorarray))').*[1 1 1];
FSUP = 3e3;
FINF = 0;
STEP = 1;
SAMPLES = ceil((FSUP-FINF)/STEP)+1;
karray  = linspace(FINF,FSUP,SAMPLES)*2*pi(); 
figure('Units','centimeters','Position',[4,4,4,4]);

%
[INPUT_matrix] = GRID_MATRIX_PN;

%
tiledlayout(1,1,"TileSpacing","tight");
nexttile
    for pf=1:1:size(GRID_MATRIX_PN,2)
        GRID_MATRIX_PN{pf} = GRID_MATRIX_PN{pf}/Yb;
        for f=1:1:size(GRID_MATRIX_PN{pf},3)
            a = real(GRID_MATRIX_PN{pf}(1,1,f));
            b = real(GRID_MATRIX_PN{pf}(2,2,f));
            c1 = real(GRID_MATRIX_PN{pf}(1,2,f));
            c2 = real(GRID_MATRIX_PN{pf}(2,1,f));
            d1 = imag(GRID_MATRIX_PN{pf}(1,2,f));
            d2 = imag(GRID_MATRIX_PN{pf}(2,1,f));
            alphamin(f) = 0.5*((a+b)-sqrt((a-b)^2+(c1+c2)^2+(d2-d1)^2));
            
            F = 0.5.*(GRID_MATRIX_PN{pf}(:,:,f) + GRID_MATRIX_PN{pf}(:,:,f)');
            alphamin2(f)         = min(eig(F));

            
        end
        % plot(karray/(2*pi),alphamin,'Color',COLORiter(pf,:))
        % hold on
        plot(karray/(2*pi),alphamin2,'Color',COLORiter(pf,:))
        hold on
    end
    plot(karray/(2*pi),zeros(size(karray,2)),'Color',[0.8500 0.3250 0.0980],'LineStyle','--')
    colormap(COLORiter)
    hc = colorbar;
    set(hc,'Ticks',0:0.2:1,'YTickLabel',{0.2:0.2:1},'FontSize',8,'FontName','Times')

    hold off
    ylabel('$\lambda_{min}$','Interpreter','Latex','FontSize',8)
    xlabel('f [Hz]','Interpreter','Latex','FontSize',8)
    set(gca,'fontname','times','fontsize',8)
    %ylim([-2 15])
    %xlim([0 3e3])
    grid on

% nexttile
%     for i=1:1:size(anglepp1,2)
%         %change angle to degrees
%         plot(karray/(2*pi),mod(anglepp1{i}*180/pi,360),'Color',COLORiter(i,:))
%         hold on
%     end
%     hold off
% nexttile
%     for i=1:1:size(anglepp1,2)
%         %change angle to degrees
%         plot(karray/(2*pi),anglepp1{i},'Color',COLORiter(i,:))
%         hold on
%     end
%     hold off
%    ylabel('$\theta_{Z_{pp}}$','Interpreter','Latex')
end