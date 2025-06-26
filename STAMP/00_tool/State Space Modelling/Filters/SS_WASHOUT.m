function ss_hp = SS_WASHOUT(Tw,input,output)
    ss_tf  = tf([Tw 0],[Tw 1]);
    [A,B,C,D] = tf2ss(ss_tf.num{1},ss_tf.den{1});

    x  = {['SG',num2str(bus),'_pss1_x1'],['SG',num2str(bus),'_pss1_x2']};
    u  = {input};
    y  = {output};
    ss_hp = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end