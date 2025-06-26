function T_XX = add_area(T_XX, T_PF)

    % To avoid errors with column 'Area' in old excel models:

    Exist_Column = any(strcmp('Area',T_PF.Properties.VariableNames));

    % Initially, Area was a column in each generator sheet. However, it is
    % easier to introduce it from the buses table in 'PF' sheet.

    % Old excels do not have column 'Area' in 'PF' sheet, so in these cases
    % this function should not be executed.    

    if Exist_Column
        for idx = 1:height(T_XX)
            T_XX.Area(idx) = T_PF.Area(T_PF.bus == T_XX.bus(idx));    
        end
    end
end

