proc write_sim_data {env name radix cycle file} {
    set fid [open $file w]
    for {set i 0} {$i <= $::now} {incr i [expr $cycle * 1000]} {
        set str [exa -env $env -radix $radix -time ${i}ps {*}$name]
        puts $fid $str
    }
    close $fid 
}

write_sim_data tb_trackingchannelinterface/uut/trackingChannelGen(0)/trackingChannel_X {accumulation_P_I_reg_s_out accumulation_P_Q_reg_s_out} decimal 1000000 1.txt