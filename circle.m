function h = circle( x, y, r )
%CIRCLE Summary of this function goes here
%   Detailed explanation goes here

d = r*2;
px = x-r;
py = y-r;
h = rectangle('Position', [px py d d], ...
                'Curvature', [1,1], ...
                'FaceColor', 'r');
daspect([1,1,1]);

end

