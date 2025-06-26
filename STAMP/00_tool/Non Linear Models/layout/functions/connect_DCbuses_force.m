function connect_DCbuses_force(fileName,hbus,hbusblock,hline,side)
%switch side 
        add_line(fileName,hbus.RConn(1),hline.LConn(1))
        add_line(fileName,hbus.RConn(2),hline.LConn(2))

        add_line(fileName,hline.RConn(1),hbusblock.LConn(1))
        add_line(fileName,hline.RConn(2),hbusblock.LConn(2))
end