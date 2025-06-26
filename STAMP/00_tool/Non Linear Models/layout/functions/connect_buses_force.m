function connect_buses_force(fileName,hbus,hbusblock,hline,side)
switch side 
    case 'l2r'
        add_line(fileName,hbus.RConn(1),hline.LConn(1))
        add_line(fileName,hbus.RConn(2),hline.LConn(2))
        add_line(fileName,hbus.RConn(3),hline.LConn(3))
        add_line(fileName,hline.RConn(1),hbusblock.LConn(1))
        add_line(fileName,hline.RConn(2),hbusblock.LConn(2))
        add_line(fileName,hline.RConn(3),hbusblock.LConn(3))   
    case 'r2l'
        add_line(fileName,hbus.LConn(1),hline.LConn(1))
        add_line(fileName,hbus.LConn(2),hline.LConn(2))
        add_line(fileName,hbus.LConn(3),hline.LConn(3))    
        add_line(fileName,hline.RConn(1),hbusblock.RConn(1))
        add_line(fileName,hline.RConn(2),hbusblock.RConn(2))
        add_line(fileName,hline.RConn(3),hbusblock.RConn(3))    
end