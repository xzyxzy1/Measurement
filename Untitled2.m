% 读取左右图像
I1 = imread('left.png');
I2 = imread('right.png');

% 加载标定参数
load('stereoParams.mat'); #这俩如果是对话框，直接注释掉就可以了

% 对左右图像进行极线矫正
[I1Rect,I2Rect] = rectifyStereoImages(I1,I2,stereoParams);

% 计算视差图
disparityMap = disparity(rgb2gray(I1Rect), rgb2gray(I2Rect));

% 显示视差图
imshow(disparityMap, [0, 64]);
