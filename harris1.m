clear;
​filename = '1.png';
X = imread(filename);     
​
Info = imfinfo(filename); 
if (Info.BitDepth > 8)
    f = rgb2gray(X);
end
​
%计算图像亮度f(x,y)在点(x,y)处的梯度-----------------------------------------------
ori_im = double(f) / 255;                   
fx = [-2 -1 0 1 2];                     % x方向梯度算子
Ix = filter2(fx, ori_im);                
​
fy = [-2; -1; 0; 1; 2];                     % y方向梯度算子
Iy = filter2(fy, ori_im);                % y方向滤波
​
%构造自相关矩阵---------------------------------------------------------------
Ix2 = Ix .^ 2;
Iy2 = Iy .^ 2;
Ixy = Ix .* Iy;
​
clear Ix;
clear Iy;
​
h= fspecial('gaussian', [7 7], 2);        % 产生7*7的高斯窗函数，sigma=2
​
Ix2 = filter2(h,Ix2);
Iy2 = filter2(h,Iy2);
Ixy = filter2(h,Ixy);
​
%提取特征点---------------------------------------------------------------
height = size(ori_im, 1);
width = size(ori_im, 2);
result = zeros(height, width);           % 纪录角点位置，角点处值为1
​
R = zeros(height, width);
Rmax = 0;                              % 图像中最大的R值
k = 0.06;
​
for i = 1 : height
    for j = 1 : width
        M = [Ix2(i, j) Ixy(i, j); Ixy(i, j) Iy2(i, j)];            
        R(i,j) = det(M) - k * (trace(M)) ^ 2;                     % 计算R
        if R(i,j) > Rmax
            Rmax = R(i, j);
        end
    end
end
​
T = 0.01 * Rmax;%固定阈值，当R(i, j) > T时，则被判定为候选角点
​
%进行局部非极大值抑制-------------------------------------
cnt = 0;
for i = 2 : height-1
    for j = 2 : width-1
        if (R(i, j) > T && R(i, j) > R(i-1, j-1) && R(i, j) > R(i-1, j) && R(i, j) > R(i-1, j+1) && R(i, j) > R(i, j-1) && ...
                R(i, j) > R(i, j+1) && R(i, j) > R(i+1, j-1) && R(i, j) > R(i+1, j) && R(i, j) > R(i+1, j+1))
            result(i, j) = 1;
            cnt = cnt+1;
        end
    end
end
​
i = 1;
    for j = 1 : height
        for k = 1 : width
            if result(j, k) == 1
                corners1(i, 1) = j;
                corners1(i, 2) = k;
                i = i + 1;
            end
        end
    end
[posc, posr] = find(result == 1);
​
figure,imshow(ori_im);
hold on;
plot(posr, posc, 'r+');
​