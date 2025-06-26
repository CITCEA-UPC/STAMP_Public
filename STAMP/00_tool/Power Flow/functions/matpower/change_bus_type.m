function [results,mpc]  = change_bus_type(mpc)

    bus = mpc.bus;

    busData = array2table(bus(:,1:2),"VariableNames",["bus","type"]);

    % Display the current bus data
    disp('Current Bus Data:');
    disp(busData);
    
    % Allow the user to make modifications
    modifyBuses = true;
    
    while modifyBuses
        % Get user input for the row to modify
        prompt = 'Enter the number of the bus you want to modify its type (1:PQ, 2:PV, 3:slack) or 0 to exit: ';
        busNum = input(prompt);
        busRow = find(busData.bus == busNum,1);
    
        if busNum == 0
            modifyBuses = false;
        elseif busNum > 0 && busRow <= height(busData)
            % Display current values for the selected bus
            disp(['Current values for Bus ', num2str(busNum), ':']);
            disp(busData(busRow, :));
    
            % Create a list of bus types
            busTypeOptions = {'PQ', 'PV', 'Slack'};
    
            % Create a dialog box for selecting a new bus type
            prompt = 'Select Bus Type:';
            dlgTitle = 'Bus Type Selection';
            numLines = 1;
            defaultAns = {busData.bus(busRow)};
            busTypeIndex = listdlg('PromptString', prompt, 'SelectionMode', 'single', 'ListString', busTypeOptions, 'Name', dlgTitle, 'ListSize', [160, 100], 'InitialValue', find(strcmp(busData.bus(busRow), busTypeOptions)));
    
            % Modify the bus type
            if ~isempty(busTypeIndex)
                newBusType = busTypeOptions{busTypeIndex};
                switch newBusType
                    case "PQ"
                        busData{busRow, 2} = 1;
                    case "PV"
                        busData{busRow, 2} = 2;
                    case "Slack"
                        busData{busRow, 2} = 3;
                end
    
                % Display the updated bus data
                disp('Updated Bus Data:');
                disp(busData);
            else
                disp('User canceled the selection.');
            end
        else
            disp('Invalid row number.');
        end
    end

    bus(:,2) = busData.type;

    mpc.bus = bus;
    [~, bus, gen, ~, ~, ~] = runpf(mpc);
    results = matpower2table(bus, gen);
end
