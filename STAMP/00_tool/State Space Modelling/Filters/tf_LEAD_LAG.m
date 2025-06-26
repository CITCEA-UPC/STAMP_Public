function tf_lead_lag = tf_LEAD_LAG(Tnum,Tden)
    tf_lead_lag  = tf([Tnum 1],[Tden 1]);
end