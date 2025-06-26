function connect_DCbuses_gen_force(fileName,hbus,hbusblock,side)
if side == 'l'
        add_line(fileName,hbus.LConn(1),hbusblock.RConn(1))
        add_line(fileName,hbus.LConn(2),hbusblock.RConn(2))
elseif side == 'r'
        add_line(fileName,hbus.RConn(1),hbusblock.RConn(1))
        add_line(fileName,hbus.RConn(2),hbusblock.RConn(2)) 
end