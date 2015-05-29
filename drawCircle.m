function im = drawCircle( im, x0, y0, radius, color, fill )

x = radius;
y = 0;
radiusError = 1 - x;

while(x >= y)
    if fill
        im = drawLine(im, color, -x + x0, y + y0, x + x0, y + y0);
        im = drawLine(im, color, y + x0, x + y0, -y + x0, x + y0);
        im = drawLine(im, color, -x + x0, -y + y0, x + x0, -y + y0);
        im = drawLine(im, color, -y + x0, -x + y0, y + x0, -x + y0);
    else
        im = drawPixel(im, color, x + x0, y + y0);
        im = drawPixel(im, color, y + x0, x + y0);
        im = drawPixel(im, color, -x + x0, y + y0);
        im = drawPixel(im, color, -y + x0, x + y0);
        im = drawPixel(im, color, -x + x0, -y + y0);
        im = drawPixel(im, color, -y + x0, -x + y0);
        im = drawPixel(im, color, x + x0, -y + y0);
        im = drawPixel(im, color, y + x0, -x + y0);
    end
    y = y + 1;

    if (radiusError<0)
      radiusError = radiusError + 2 * y + 1;
    else
      x = x - 1;
      radiusError = radiusError + 2 * (y - x + 1);
    end
end

end
