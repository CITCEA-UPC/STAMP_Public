function tf_hp = tf_WASHOUT(Tw)
    % sTw / sTw + 1
    tf_hp  = tf([Tw 0],[Tw 1]);
end