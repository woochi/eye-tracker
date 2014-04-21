function drawCircle( image, x0, y0, radius, color, fill )

if nargin < 5
    fill = false;
end

x = radius;
y = 0;
radiusError = 1 - x;

while(x >= y)
    if fill
        drawLine(image, color, -x + x0, y + y0, x + x0, y + y0);
        drawLine(image, color, y + x0, x + y0, -y + x0, x + y0);
        drawLine(image, color, -x + x0, -y + y0, x + x0, -y + y0);
        drawLine(image, color, -y + x0, -x + y0, y + x0, -x + y0);
    else
        drawPixel(image, color, x + x0, y + y0);
        drawPixel(image, color, y + x0, x + y0);
        drawPixel(image, color, -x + x0, y + y0);
        drawPixel(image, color, -y + x0, x + y0);
        drawPixel(image, color, -x + x0, -y + y0);
        drawPixel(image, color, -y + x0, -x + y0);
        drawPixel(image, color, x + x0, -y + y0);
        drawPixel(image, color, y + x0, -x + y0);
    end
    y = y + 1;

    if (radiusError<0)
      radiusError = radiusError + 2 * y + 1;
    else
      x = x - 1;
      radiusError = radiusError + 2 * (y - x + 1);
    end
end
