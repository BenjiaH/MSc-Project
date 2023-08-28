-- prompt mixing
if (replica_code = '1') then
    post_carr_code_mix_P_I_i <= post_carr_mix_I_i;
    post_carr_code_mix_P_Q_i <= post_carr_mix_Q_i;
else
    post_carr_code_mix_P_I_i <= -post_carr_mix_I_i;
    post_carr_code_mix_P_Q_i <= -post_carr_mix_Q_i;
end if;