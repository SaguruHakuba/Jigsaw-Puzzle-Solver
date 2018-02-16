function [grad] = get_gradient(gray_img)

sobelh = [1 2 1; 0 0 0; -1 -2 -1]/8;
sobelv = [1 0 -1; 2 0 -2; 1 0 -1]/8;

horizontal = filter2(sobelh,gray_img);
vertical = filter2(sobelv,gray_img);

grad = uint8(8*(sqrt(horizontal.^2+vertical.^2)));
end