function [x0] = add_angleRef(fileName,x0,y0,dx,dy,deltax,fb,area)

x0 = x0+3*dx+deltax;
    
    add_block('simulink/Sources/Constant',      [fileName '/Constant_2pif' num2str(area)], 'MakeNameUnique','on','Position',[x0 y0 x0+dx y0+dy]);
    set_param([fileName '/Constant_2pif' num2str(area)],'Value',['2*pi*' num2str(fb)],'ShowName','off');

    add_block('simulink/Continuous/Integrator', [fileName '/Integrator' num2str(area)], 'MakeNameUnique','on','Position',   [x0+2*dx y0 x0+3*dx y0+dy]);
    add_line(fileName,['Constant_2pif' num2str(area) '/1'],['Integrator' num2str(area) '/1'])

    add_block('simulink/Sources/Constant',      [fileName '/Constant_pi2' num2str(area)], 'MakeNameUnique','on','Position', [x0 y0+2*dy x0+dx y0+3*dy]);
    set_param([fileName ['/Constant_pi2' num2str(area)]],'Value','-pi/2','ShowName','off');

    add_block('simulink/Math Operations/Sum', [fileName '/Sum' num2str(area)], 'MakeNameUnique','on','Position',            [x0+4*dx y0 x0+5*dx y0+dy]);
    add_line(fileName,['Integrator' num2str(area) '/1'],['Sum' num2str(area) '/1'])
    add_line(fileName,['Constant_pi2' num2str(area) '/1'],['Sum' num2str(area) '/2'],'autorouting','smart')
    
    add_block('simulink/Signal Routing/Goto',   [fileName '/GotoAngle' num2str(area)], 'MakeNameUnique','on','Position',    [x0+6*dx y0 x0+9*dx y0+dy]);
    set_param([fileName '/GotoAngle' num2str(area)],'GotoTag',['angle_ref' num2str(area)],'TagVisibility','global','ShowName','off');
    add_line(fileName,['Sum' num2str(area) '/1'],['GotoAngle' num2str(area) '/1'])

x0 = x0+9*dx + deltax;
    
end

