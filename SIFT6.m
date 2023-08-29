img1ori = imread('1.png');
img1 = single(rgb2gray(img1ori));  %single就是转换成单精度的，之前肯定对double更熟悉一点吧
                                   %因为后面的vl_sift的输入须要用到单精度灰度图像
%图片2要识别对于的物体             
img2ori = imread('2.png');
img2 = single(rgb2gray(img2ori));
 
%% 提取SIFT特征，匹配特征点
[f1, d1] = vl_sift(img1,'Levels',5,'PeakThresh', 4); 
[f2, d2] = vl_sift(img2,'Levels',5,'PeakThresh', 5);  
%f1为生成的四元组[x,y,s,th],分别是特征点的x，y坐标，s为长度空间大小，th指的是主方向
%d1是特征描述子，也就是那个128维的向量
[matches, scores] = vl_ubcmatch(d1, d2);
[dump,scoreind]=sort(scores,'ascend');
 
 
%% 绘制组合图片
newfig=zeros(size(img1,1), size(img1,2)+size(img2,2),3);  %新构建一个3维数组，行为图片1的
                                                         %行数，列为图片1和图片2的列数和
newfig(:,1:size(img1,2),:) = img1ori;
newfig(1:size(img2,1) ,(size(img1,2)+1):end,:)=img2ori;
newfig=uint8(newfig);
figure;
image(newfig);   % 绘制组合图片
axis image
% colormap(gray)
 
%% 绘制匹配特征点
figure;
image(newfig); % 绘制组合图片+匹配对于的特征点
axis image
f2Moved=f2;  %因为此时图像在x方向发生了平移的，需要平移的大小为图1的列数
m=size(img1,2)
f2Moved(1,:) = f2Moved(1,:)+size(img1,2);
h1 = vl_plotframe(f1);  %对之前的四元组在组合照片上进行绘画
h2 = vl_plotframe(f2Moved);
set(h1,'color','g','linewidth',2) ;
set(h2,'color','r','linewidth',2);
hold on
% 绘制scores前10%
plotRatio=0.1;
for i= 1:fix(plotRatio*size(matches,2))  %fix是取整函数，这里仅画出找到的匹配的前10%
    idx = scoreind(i);
    line([f1(1,matches(1,idx)) f2Moved(1,matches(2,idx))],...
    [f1(2,matches(1,idx)) f2Moved(2,matches(2,idx))], 'linewidth',1, 'color','b')
end
hold off
%倒数第四行的...是因为matlab一行装不下，属于行行连接符