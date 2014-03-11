function [] = show_collage( images, screen, window )

  per_row = 5;
  per_col = 2;

  [screen_width, screen_height] = Screen('WindowSize', screen);
  collage_width = screen_width - 200;
  collage_height = screen_height - 200;
  border = 10;

  image_count = length(images);
  image_size = [collage_height/per_col collage_width/per_row];

  % Luo uusi kollaasikuva
  collage = uint8(zeros(collage_height + border * per_col, ...
      collage_width + border * per_row, 3));
  collage(:,:,:) = 255;

  for i = 1:image_count
      % Yhtenäistä kuvan koko kollaasia varten
      resized_image = imresize(images{i}, image_size);
      col = mod(i-1, per_row);
      row = floor((i-1)/per_row);
      offsety = border * (row + 1);
      offsetx = border * (col + 1);
    
      % Siirrä kuva kollaasiin
      collage((image_size(1)*row+offsety+1):(image_size(1)*(row+1)+offsety), ...
          (image_size(2)*col+offsetx+1):(image_size(2)*(col+1)+offsetx), ...
          :) = resized_image;
  end

  Screen('PutImage', window, collage); % Piirrä kuva puskuriin
  Screen('Flip', window); % Näytä puskuroitu kuva

end

function 
