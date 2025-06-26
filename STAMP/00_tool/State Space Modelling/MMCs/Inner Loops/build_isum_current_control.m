function isum_current_control = build_isum_current_control(kp, ki, number)
    % Additive current control (only 0 sequence)
    A = [0];
    B = [1 -1 0];
    C = [-ki];
    D = [-kp kp 1];

    x = { join(['IPC',num2str(number),'.PI_isum0']) };

    u = { join(['IPC',num2str(number),'.isum0_ref'])      ;... 
          join(['IPC',num2str(number),'.isum0_delay'])    ;... 
          join(['IPC',num2str(number),'.vDC_delay'])}     ;

    y = { join(['IPC',num2str(number),'.vsum0_precmd']) }  ;

    isum_current_control = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);

    % Additive current control (only 0 sequence)
    % A = [0];
    % B = [1 -1 0];
    % C = [-ki;
    %       0];
    % D = [-kp kp 1;
    %       0 -3 0];
    % 
    % x = { join(['IPC',num2str(number),'.PI_isum0']) };
    % 
    % u = { join(['IPC',num2str(number),'.isum0_ref'])      ;... 
    %       join(['IPC',num2str(number),'.isum0_delay'])    ;... 
    %       join(['IPC',num2str(number),'.vDC_delay'])}     ;
    % 
    % y = { join(['IPC',num2str(number),'.vsum0_precmd']) ;...
    %       join(['IPC',num2str(number),'.iDC'])}  ;
    % 
    % isum_current_control = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end