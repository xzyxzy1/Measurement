%MatLab角点检测程序harris。

 

ori_im2=rgb2gray(imread('1.png'));    
 %ori_im2=imresize(ori_im2',0.50,'bicubic');  %加上这句图就变成竖着的了  

fx = [5 0 -5;8 0 -8;5 0 -5];          % % la gaucienne，ver axe x
Ix = filter2(fx,ori_im2);              % la convolution vers axe x
fy = [5 8 5;0 0 0;-5 -8 -5];          % la gaucienne，ver axe y
Iy = filter2(fy,ori_im2);              % la convolution vers axe y
Ix2 = Ix.^2;
Iy2 = Iy.^2;
Ixy = Ix.*Iy;
clear Ix;
clear Iy;

h= fspecial('gaussian',[3 3],2);      % générer une fonction gaussienne，sigma=2

Ix2 = filter2(h,Ix2);
Iy2 = filter2(h,Iy2);
Ixy = filter2(h,Ixy);

height = size(ori_im2,1);
width = size(ori_im2,2);
result = zeros(height,width);         % enregistrer la position du coin

R = zeros(height,width);

K=0.04;
Rmax = 0;                              % chercher la valeur maximale de R
for i = 1:height
    for j = 1:width
        M = [Ix2(i,j) Ixy(i,j);Ixy(i,j) Iy2(i,j)];         
        R(i,j) = det(M)-K*(trace(M))^2;                     % % calcule R
        if R(i,j) > Rmax
           Rmax = R(i,j);
        end;
    end;
end;

cnt = 0;
for i = 2:height-1
    for j = 2:width-1
        % réduire des valuers minimales ，la taille de fenetre 3*3
        if R(i,j) > 0.01*Rmax && R(i,j) > R(i-1,j-1) && R(i,j) > R(i-1,j) && R(i,j) > R(i-1,j+1) && R(i,j) > R(i,j-1) && R(i,j) > R(i,j+1) && R(i,j) > R(i+1,j-1) && R(i,j) > R(i+1,j) && R(i,j) > R(i+1,j+1)
            result(i,j) = 1;
            cnt = cnt+1;
        end;
    end;
end;

[posr2, posc2] = find(result == 1);
cnt                                      % compter des coins
figure
imshow(ori_im2);
hold on;
plot(posc2,posr2,'w*');