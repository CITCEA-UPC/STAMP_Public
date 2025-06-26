if k==FINF*2*pi
        for num=1:1:nl                                                       
        eval(sprintf('lambda%d(1) = lambda(num,num);',num))
        end
else
        ocpos = zeros(1,nl);

        for mn=1:1:nl
        clear dis
            for sn=1:1:nl
                if ocpos(sn) == 0
                eval(sprintf('dis(sn,1)= abs(lambda%d(n-1)-lambda(mn,mn));',sn))
                else
                flag           = ocpos(sn);
                dis(flag,1)    = ERROR;
                end
            end
            [leng,pos]     = min(dis); 
            ocpos(pos)      = pos;
            eval(sprintf('lambda%d(n) = lambda(mn,mn);',pos))
        end
end