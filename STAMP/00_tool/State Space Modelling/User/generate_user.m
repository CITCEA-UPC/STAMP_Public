function [l_blocks, T_user] = generate_user(l_blocks, T_user)

    for user = 1:1:size(T_user.bus,1)
        % prompt = {'matrix A:', ...
        %           'matrix B:', ...
        %           'matrix C:', ...
        %           'matrix D:'};
        % 
        % dlgtitle = ['Input User' num2str(T_user.number(user)) ' Parameters'];
        % fieldsize = [1 45; 1 45;1 45;1 45];
        % definput = {'','','',''};
        % matrices = inputdlg(prompt,dlgtitle,fieldsize,definput);
        % A = str2num(matrices{1})
        % B = str2num(matrices{2})
        % C = str2num(matrices{3})
        % D = str2num(matrices{4})

        waitfor(msgbox(join(["Select User-",num2str(user),'A, B, C, D matrix file.' ...
            'This data must be saved as .mat file containing the matrices' ...
            'A, B, C and D named as "A","B","C" and "D".'])));
        [file,location] = uigetfile('*.mat','Select the A matrix file');
        
        user_ss = load(join([location file]));

        try
            user_ss.A;
        catch ME
             rethrow(ME)
        end
        try
            user_ss.B;
        catch ME
             rethrow(ME)
        end
        try
            user_ss.C;
        catch ME
             rethrow(ME)
        end
        try
            user_ss.D;
        catch ME
             rethrow(ME)
        end
        output  = {['USER' num2str(T_user.number(user)) '.iq'],['USER' num2str(T_user.number(user)) '.id']};
        input = { ['NET.vn' num2str(T_user.bus(user)) 'q'] , ['NET.vn' num2str(T_user.bus(user)) 'd'],['REF_w',num2str(T_user.SyncArea(user))]};

        l_blocks{end+1} = ss(user_ss.A,user_ss.B,user_ss.C,user_ss.D,'inputname',input,'outputname',output);

        for i=1:1:size(l_blocks{end}.statename)
            l_blocks{end}.StateName{i} = join(['USER-',num2str(T_user.number(user)),'.x',num2str(i)]);
        end

        T_user.A{user} = user_ss.A;
        T_user.B{user} = user_ss.B;
        T_user.C{user} = user_ss.C;
        T_user.D{user} = user_ss.D;
    end

end