function im = drawPixel( im, color, x, y )

if x > 0 && y > 0
    im(y, x, 1) = color(1);
    im(y, x, 2) = color(2);
    im(y, x, 3) = color(3);
end

end
