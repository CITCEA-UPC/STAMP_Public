function NET = get_specific_NET(connect_mtx_PI,T_NET)
    xis=1;
    index=[];
    for i=1:1:size(connect_mtx_PI,1)
        for j=1:1:size(connect_mtx_PI,2)
            if connect_mtx_PI(i,j)==1
                if not(isempty(T_NET(T_NET.bus_from==i & T_NET.bus_to==j,:)))
                    index(xis) = find(T_NET{:,'bus_from'}==i & T_NET{:,'bus_to'}==j);
                    xis=xis+1;
                end
            end
        end
    end
    NET=T_NET(index,:);
end