function connect_DCbuses_force2(fileName,hbus,hbusblock,hline,side)
%switch side 
        add_line(fileName,hbus.RConn(1),hline.LConn(1))
        add_line(fileName,hbus.RConn(2),hline.LConn(2))

        add_line(fileName,hline.RConn(1),hbusblock.RConn(1))
        add_line(fileName,hline.RConn(2),hbusblock.RConn(2))
end