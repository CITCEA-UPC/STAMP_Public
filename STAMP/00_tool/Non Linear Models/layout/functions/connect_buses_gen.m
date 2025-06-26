function connect_buses_gen(fileName,hbus,hbusblock,side)
if side == 'l'
        add_line(fileName,hbus.LConn(1),hbusblock.RConn(1),'autorouting','smart')
        add_line(fileName,hbus.LConn(2),hbusblock.RConn(2),'autorouting','smart')
        add_line(fileName,hbus.LConn(3),hbusblock.RConn(3),'autorouting','smart')
elseif side == 'r'
        add_line(fileName,hbus.RConn(1),hbusblock.RConn(1),'autorouting','smart')
        add_line(fileName,hbus.RConn(2),hbusblock.RConn(2),'autorouting','smart')
        add_line(fileName,hbus.RConn(3),hbusblock.RConn(3),'autorouting','smart')     
end