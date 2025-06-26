function set_breaker_state(element,number,newState)

    % Import global variables names
    setup_globals; 

    if newState == "open"
        newState = 0;
    elseif newState == "close"
        newState = 1;
    else
        warning('New state not recognised')
    end

    switch element
        case "line"
            if newState
                T_NET_0.state(T_NET_0.number == number) = 1;
            else
                T_NET_0.state(T_NET_0.number == number) = 0;
            end
            T_NET = T_NET_0(T_NET_0.state == 1,:);
            
        case "trafo"
            if newState
                T_trafo_0.state(T_trafo_0.number == number) = 1;
            else
                T_trafo_0.state(T_trafo_0.number == number) = 0;
            end
            T_trafo = T_trafo_0(T_trafo_0.state == 1,:);

        case "DC_line"
            if newState
                T_DC_NET_0.state(T_DC_NET_0.number == number) = 1;
            else
                T_DC_NET_0.state(T_DC_NET_0.number == number) = 0;
            end
            T_DC_NET = T_DC_NET_0(T_DC_NET_0.state == 1,:);

        case "load"
            if newState
                T_load_0.state(T_load_0.number == number) = 1;
            else
                T_load_0.state(T_load_0.number == number) = 0;
            end
            T_load = T_load_0(T_load_0.state == 1,:);
                
        case "TH"
            if newState
                T_TH_0.state(T_TH_0.number == number) = 1;
            else
                T_TH_0.state(T_TH_0.number == number) = 0;
            end
            T_TH = T_TH_0(T_TH_0.state == 1,:);

        case "SG"
            if newState
                T_SG_0.state(T_SG_0.number == number) = 1;
            else
                T_SG_0.state(T_SG_0.number == number) = 0;
            end
            T_SG = T_SG_0(T_SG_0.state == 1,:);
             
        case "VSC"
            if newState
                T_VSC_0.state(T_VSC_0.number == number) = 1;
            else
                T_VSC_0.state(T_VSC_0.number == number) = 0;
            end
            T_VSC = T_VSC_0(T_VSC_0.state == 1,:);
                 
        case "MMC"
            if newState
                T_MMC_0.state(T_MMC_0.number == number) = 1;
            else
                T_MMC_0.state(T_MMC_0.number == number) = 0;
            end
            T_MMC = T_MMC_0(T_MMC_0.state == 1,:);
                
        case "user"
            if newState
                T_user_0.state(T_user_0.number == number) = 1;
            else
                T_user_0.state(T_user_0.number == number) = 0;
            end
            T_user = T_user_0(T_user_0.state == 1,:);
               
        otherwise
            warning('breaker name not found')
    end
end

