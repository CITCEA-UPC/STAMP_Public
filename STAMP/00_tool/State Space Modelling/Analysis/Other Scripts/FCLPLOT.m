function out = FCLPLOT(LAMBDA,fr,nl,OPTION2,NSUB,num)

    eval(sprintf('mag%d  = abs(LAMBDA);',num,num));
    eval(sprintf('real%d = real(LAMBDA);',num,num));
    eval(sprintf('imag%d = imag(LAMBDA);',num,num));
    eval(sprintf('ph%d   = angle(LAMBDA)*180/(pi);',num,num)); 
       
    
        switch OPTION2
            
            case 'MAGREAL' 
                
            subplot(2,1,1);
            eval(sprintf('pmag=plot(fr,mag%d);',num));
            set(pmag,'LineWidth',2,'Color',[0.2 (num/nl) 0.6]);
            hold all
            
            subplot(2,1,2);
            eval(sprintf('preal=plot(fr,real%d);',num));
            set(preal,'LineWidth',2,'Color',[0.2 (num/nl) 0.6]); 
            hold all
            
            case 'MAGPH' 
            
            subplot(2,1,1);
            eval(sprintf('pmag=plot(fr,mag%);',num));
            set(pmag,'LineWidth',2,'Color',[0.2 (num/nl) 0.6]);
            hold all
            
            subplot(2,1,2);
            eval(sprintf('pph=plot(fr,ph%d);',num));
            set(pph,'LineWidth',2,'Color',[0.2 (num/nl) 0.6]);
            hold all
            
            case 'BODE' 
            
            subplot(2,1,1);
            eval(sprintf('pmag=plot(fr,mag2db(mag%d));',num));
            set(pmag,'LineWidth',2,'Color',[0.2 (num/nl) 0.6]);
            hold all
            
            subplot(2,1,2);
            eval(sprintf('pph=plot(fr,ph%d);',num));
            set(pph,'LineWidth',2,'Color',[0.2 (num/nl) 0.6]);
            hold all
            
            case 'MAG'
                
            subplot(NSUB,1,1);
            eval(sprintf('pmag=plot(fr,mag%d);',num));
            set(pmag,'LineWidth',2,'Color',[0.2 (num/nl) 0.6]);
            hold all
            
            case 'REAL'
            
            subplot(NSUB,1,NSUB);
            eval(sprintf('preal=plot(fr,real%d);',num));
            set(preal,'LineWidth',2,'Color',[0.2 (num/nl) 0.6]);
            hold all
            
            case 'IMAG'
            
            subplot(NSUB,1,NSUB);
            eval(sprintf('pimag=plot(fr,imag%d);',num));
            set(pimag,'LineWidth',2,'Color',[0.2 (num/nl) 0.6]);
            hold all
            
            case 'NYQ'
                
            subplot(NSUB,1,1);    
            eval(sprintf('nyq = plot(real%d,imag%d);',num,num));
            set(nyq,'LineWidth',2,'Color',[0.2 (num/(nl)) 0.6]); 
            hold all
        end
    end