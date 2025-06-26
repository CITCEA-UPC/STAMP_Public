%% Stores original topology fo rupdating the state of breakers (in read_data)

% if areBreakers
% 
%     % T_breaker:                Stores state of breakers 
%     
%     % T_breaker should come from grid topology data. 
%     % If not provided, a breaker is assumed in each line & generator element POC.
%     
%     T_breaker = [T_NET(:,"number"); 
%                  T_trafo(:,"number");
%                  T_DC_NET(:,"number");
%                  T_load(:,"number");
%                  T_TH(:,"number");
%                  T_SG(:,"number");
%                  T_VSC(:,"number");
%                  T_MMC(:,"number");
%                  T_user(:,"number")];
%     
%     T_breaker.element = [repmat("line",height(T_NET),1);
%                          repmat("trafo",height(T_trafo),1);
%                          repmat("DC_line",height(T_DC_NET),1);
%                          repmat("load",height(T_load),1);
%                          repmat("TH",height(T_TH),1);
%                          repmat("SG",height(T_SG),1);
%                          repmat("VSC",height(T_VSC),1);
%                          repmat("MMC",height(T_MMC),1);
%                          repmat("user",height(T_user),1);];
%     
%     T_breaker.breaker_ID    = [1:height(T_breaker)]';
%     T_breaker.state         = ones(height(T_breaker),1);
%     T_breaker.change        = zeros(height(T_breaker),1); 
%     
%     T_NET_0           = T_NET;
%     T_DC_NET_0        = T_DC_NET;
%     T_trafo_0         = T_trafo;
%     T_load_0          = T_load;
%     T_TH_0            = T_TH;
%     T_SG_0            = T_SG;
%     T_VSC_0           = T_VSC;
%     T_MMC_0           = T_MMC;
%     T_user_0          = T_user;

% end



%% Update state of switches (open/close lines)

if areBreakers
    
    % Update state of switches
    new_state        = [1 1 1 0 1]'; %ones(height(T_breaker),1); 
    % Determine which breakers have changed
    T_breaker.change = ~(T_breaker.state & new_state);     

    if any(T_breaker.change)
        T_changes = groupcounts(T_breaker(T_breaker.change == true,:),{'element','change'});
        for idx_el = 1:height(T_changes)
            element = T_changes.element{idx_el};
            switch element
                case "line"
                    T_NET       = breakers(T_breaker, T_NET_0, element);
                case "trafo"
                    T_trafo     = breakers(T_breaker, T_trafo_0, element);
                case "DC_line"
                    T_DC_line   = breakers(T_breaker, T_DC_line_0, element);
                case "load"
                    T_load      = breakers(T_breaker, T_load_0, element);                
                case "TH"
                    T_TH        = breakers(T_breaker, T_TH_0, element);                  
                case "SG"
                    T_SG        = breakers(T_breaker, T_SG_0, element);                   
                case "VSC"
                    T_VSC       = breakers(T_breaker, T_VSC_0, element);                   
                case "MMC"
                    T_MMC       = breakers(T_breaker, T_MMC_0, element);                 
                case "user"
                    T_user      = breakers(T_breaker, T_user_0, element);                
                otherwise
                    warning('breaker not found')
            end
        end
        T_breaker.state = new_state;
        T_breaker.change = zeros(height(T_breaker),1); 
    end
    
end

function T_XX = breakers(T_breaker, T_XX_0, element)
    state = ones(1:height(T_XX_0));
    state(T_breaker.number(T_breaker.element == element & T_breaker.change == true)) = T_breaker.state(T_breaker.element == element & T_breaker.change == true);
    state(T_breaker.number(T_breaker.element == element & T_breaker.change == true)) = ~ state(T_breaker.number(T_breaker.element == element & T_breaker.change == true));
    T_XX = T_XX_0(state == 1,:);     
end


%% Re-name nodes to have consecutive numbers (not implemented yet)

% It is not necessary for the code to work, but optimizes the size of the
% connectivity-matrix

    % run rename_nodes.m