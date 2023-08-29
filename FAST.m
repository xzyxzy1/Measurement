clear all;
close all;
%%
pic=imread('1.png');
img=pic;
[M N D]=size(pic);
if D==3
    pic=rgb2gray(pic);
end
%%
mask=[0 0 1 1 1 0 0;...
      0 1 0 0 0 1 0;...
      1 0 0 0 0 0 1;...
      1 0 0 0 0 0 1;...
      1 0 0 0 0 0 1;...
      0 1 0 0 0 1 0;...
      0 0 1 1 1 0 0];
mask=uint8(mask);
threshold=50;
figure;imshow(img);title('FAST角点检测');hold on;
tic;
for i=4:M-3
    for j=4:N-3%若I1、I9与中心I0的差均小于阈值，则不是候选点
        delta1=abs(pic(i-3,j)-pic(i,j))>threshold;
        delta9=abs(pic(i+3,j)-pic(i,j))>threshold;
        delta5=abs(pic(i,j+3)-pic(i,j))>threshold;
        delta13=abs(pic(i,j-3)-pic(i,j))>threshold;
        if sum([delta1 delta9 delta5 delta13])>=3
            block=pic(i-3:i+3,j-3:j+3);
            block=block.*mask;%提取圆周16个点
            pos=find(block);
            block1=abs(block(pos)-pic(i,j))/threshold;
            block2=floor(block1);
            res=find(block2);
            if size(res,1)>=12
                plot(j,i,'ro');
            end
        end
    end
end
toc;
%%