function connect_buses(fileName,hbus,hbusblock,hline,side)
if side == 'l'
        add_line(fileName,hbus.LConn(1),hline.RConn(1),'autorouting','smart')
        add_line(fileName,hbus.LConn(2),hline.RConn(2),'autorouting','smart')
        add_line(fileName,hbus.LConn(3),hline.RConn(3),'autorouting','smart')
        add_line(fileName,hline.LConn(1),hbusblock.RConn(1),'autorouting','smart')
        add_line(fileName,hline.LConn(2),hbusblock.RConn(2),'autorouting','smart')
        add_line(fileName,hline.LConn(3),hbusblock.RConn(3),'autorouting','smart')   
elseif side == 'r'
        add_line(fileName,hbus.RConn(1),hline.LConn(1),'autorouting','smart')
        add_line(fileName,hbus.RConn(2),hline.LConn(2),'autorouting','smart')
        add_line(fileName,hbus.RConn(3),hline.LConn(3),'autorouting','smart')    
        add_line(fileName,hline.RConn(1),hbusblock.LConn(1),'autorouting','smart')
        add_line(fileName,hline.RConn(2),hbusblock.LConn(2),'autorouting','smart')
        add_line(fileName,hline.RConn(3),hbusblock.LConn(3),'autorouting','smart')   
end