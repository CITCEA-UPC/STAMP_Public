function tf_lp = tf_LP(K,T)
    % K / sT + 1
    tf_lp  = tf([K],[T 1]);
end