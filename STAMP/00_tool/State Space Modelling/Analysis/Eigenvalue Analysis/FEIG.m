function [T_lambda, out] = FEIG(FUNCTION,CCOLOR,marker,plotYes)

[RV,D,LV]   = eig(FUNCTION.a); 
lambda(:,1) = diag(D);


%   Table
sz = [size(lambda,1) 6];
varTypes = ["double","double","double","double","double","string"];
varNames = ["Mode","Real","Imaginary","Frequency","damping", "damp<0.05?"];
T_lambda = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

for i=1:1:size(lambda)
    sigma(i,1)  = real(lambda(i,1));
    omega(i,1)  = imag(lambda(i,1));
    damp_ratio(i) = -sigma(i,1)./abs(lambda(i,1));
    freq(i)     = abs(omega(i))/(2*pi);
    if (damp_ratio(i)<= 0.05) 
        damp_LT005(i)  = "<!>";
    else
        damp_LT005(i)  = "";
    end
    T_lambda(i,:)={i sigma(i,1) omega(i,1) freq(i) damp_ratio(i) damp_LT005(i)};
end

T_lambda = sortrows(T_lambda,2,'descend');
id = [1:height(T_lambda)]';
T_lambda.Mode = id;


%   Plot
    if plotYes
        fig=figure;
        COLOR    = CCOLOR;
        POSITION = [0.22 0.20 0.75 0.75];
        set(gcf,'color','w');
        set(groot,'defaultAxesTickLabelInterpreter','latex');  
        set(groot,'defaulttextinterpreter','latex');
        set(groot,'defaultLegendInterpreter','latex');
        
        p = plot(eig(FUNCTION.A),marker,'Color',COLOR,'MarkerSize',3,'LineWidth',1.5);
        p.MarkerFaceColor = CCOLOR;
        xlabel('Real axis','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
        ylabel('Imaginary axis','FontName', 'Times New Roman','FontAngle','normal','FontWeight','bold','FontSize',11)
        set(gca,'FontName','Times New Roman','FontSize',11,'Position',POSITION)
        grid on
        set(gcf,'Position',[100 100 300 250])
    end
end