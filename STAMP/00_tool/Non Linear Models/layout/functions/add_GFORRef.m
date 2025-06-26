function [x0] = add_GFORRef(fileName,x0,y0,dx,dy,deltax,num_slk,area)

x0 = x0+3*dx+deltax;
   
   h_from = add_block('simulink/Signal Routing/From',  [fileName '/theta_GFOR' ], 'MakeNameUnique','on','Position',[x0 y0 x0+3*dx y0+dy]);
   set_param(h_from,'GotoTag',['theta_GFOR' num2str(num_slk)],'TagVisibility','global','ShowName','off');
    
   h_goto = add_block('simulink/Signal Routing/Goto',   [fileName '/GotoAngle' num2str(area)], 'MakeNameUnique','on','Position',    [x0+4*dx y0 x0+7*dx y0+dy]);
   set_param([fileName '/GotoAngle' num2str(area)],'GotoTag',['angle_ref' num2str(area)],'TagVisibility','global','ShowName','off');

   add_line(fileName,get_param(h_from,'PortHandles').Outport(1), get_param(h_goto,'PortHandles').Inport(1))

x0 = x0+7*dx + deltax;
    
end

