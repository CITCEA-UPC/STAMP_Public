function [Xq2,Xd2] = rotation_vect(Xq1,Xd1,theta)
Xq2 = cos(theta).*Xq1-sin(theta).*Xd1;
Xd2 = sin(theta).*Xq1+cos(theta).*Xd1;
end

