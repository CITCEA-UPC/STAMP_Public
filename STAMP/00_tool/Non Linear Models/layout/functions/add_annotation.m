function y0 = add_annotation(fileName, text, x0, y0, dx, dy)

    h_title = Simulink.Annotation(fileName,text);
    h_title.FontName = 'Times New Roman';
    h_title.FontSize = 16;
    h_title.Position = [x0 y0 x0+dx y0+dy];
    h_title.HorizontalAlignment = 'center';
    y0 = y0+dy;

end