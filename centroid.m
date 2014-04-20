function [x, y] = centroid( samples )
%CENTROID Calculate centroid of sample window points.

x = 0;
y = 0;

for i = 1:length(samples)
    sample = samples(i);
    x = x + (sample.lporx + sample.rporx) * 0.5;
    y = y + (sample.lpory + sample.rpory) * 0.5;
end

x = x / length(samples);
y = y / length(samples);

end

