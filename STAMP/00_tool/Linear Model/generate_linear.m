function [] = generate_linear(ss_sys,fileName,tstep,Tsim,deltax)

try
    sys = new_system(fileName);
    load_system(fileName);
    
        % To Workspace
        x0_ini = 140;
        y0_ini = 95;
        width_tw = 100;
        height_tw = 15;
        delta_y = height_tw*2;
        idx_pos = 0;
        names_out = ss_sys.OutputName;
    
        for idx = 1:length(ss_sys.OutputName) 
            x0 = x0_ini;
            y0 = y0_ini + delta_y*(idx_pos);
            name_tw = strrep(names_out{idx},'.','_');
            add_block('simulink/Sinks/To Workspace', [fileName '/To Workspace' num2str(idx)], 'Position', [x0 y0 x0+width_tw y0+height_tw]); 
            set_param([fileName '/To Workspace' num2str(idx)],'VariableName',[name_tw],'SaveFormat','Array','SampleTime','sim_config.Tsample')
            idx_pos = idx_pos+1;
        end
        
        % Demux
        x0_demux = x0_ini-50;
        y0_demux = y0_ini+2;
        add_block('simulink/Signal Routing/Demux', [fileName '/Demux'], 'MakeNameUnique','on');
        set_param([fileName '/Demux'],'Outputs',num2str(length(ss_sys.OutputName)),'Position',[x0_demux y0_demux x0_demux+5 y0])
    
        % State-Space
        width_ss = 60;
        height_ss = 30;
        x0_ss = x0_demux-width_ss-50;
        y0_ss = (y0_ini+y0)/2;
        add_block('simulink/Continuous/State-Space', [fileName '/State-Space'], 'MakeNameUnique','on');
        set_param([fileName '/State-Space'],'Position',[x0_ss y0_ss x0_ss+width_ss y0_ss+height_ss],'A','ss_sys.A','B','ss_sys.B','C','ss_sys.C','D','ss_sys.D');
   
        % Add clock

        h_clock   = add_block('simulink/Sources/Clock', [fileName '/clock'],'Position', [x0_ini      y0_ini-58 x0_ini+25   y0_ini-32],'ShowName','off'); 
        h_display = add_block('simulink/Sinks/Display', [fileName '/display'],'Position', [x0_ini+2*25 y0_ini-58 x0_ini+4*25 y0_ini-32],'ShowName','off'); 
        add_line(fileName,get_param(h_clock,'PortHandles').Outport(1), get_param(h_display,'PortHandles').Inport(1))
        
        % Step
        width_step = 30;
        height_step = 30;
        x0_step = x0_ss-width_step-50;
        y0_step = y0_ss;
    
        names_in = ss_sys.InputName{1};
        names_step = strrep(names_in,'.','_');
        add_block('simulink/Sources/Step', [fileName '/Step-' names_step], 'MakeNameUnique','on');
        set_param([fileName '/Step-' names_step],'Time','tstep_lin','Position',[x0_step y0_step x0_step+width_step y0_ss+height_step],'Before','0','After','delta_u');
        %set_param([fileName '/Step-' names_step],'Time',num2str(tstep),'Position',[x0_step y0_step x0_step+width_step y0_ss+height_step],'Before','0','After',num2str(deltax));
        %set_param([fileName '/Step-' names_step],'Time',num2str(tstep),'Before','0','After','0.05');
    
        % Lines
        add_line(fileName,['Step-' names_step '/1'],'State-Space/1')
        add_line(fileName,'State-Space/1','Demux/1')
        for idx = 1:length(ss_sys.OutputName) 
            add_line(fileName,['Demux/' num2str(idx)],['To Workspace' num2str(idx) '/1'])
        end
    
        %get_param([fileName,'/To Workspace'],'dialogparameters')
        %get_param([fileName,'/Demux'],'Position')
    
        set_param(fileName, 'Solver', 'ode45', 'StopTime', 'Tsim_lin')
        %set_param(fileName, 'Solver', 'ode45', 'StopTime', num2str(Tsim))

        save_system(fileName,['00_tool/Linear Model/models/' fileName]);
        open(fileName)

catch ME
    errorMessage = sprintf('Error at line %d.\n\nError Message:\n%s', ME.stack(1).line, ME.message);
    fprintf(1, '%s\n', errorMessage);
    save_system(fileName,['00_tool/Linear Model/models' fileName])
    delete(['00_tool/Linear Model/models/' fileName '.slx'])
end