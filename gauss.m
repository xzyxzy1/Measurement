function y=gauss(x,sigama)
%y--滤波后的图像
%x--需滤波的图像
%sigama--高斯滤波核；
n=round(6*sigama);%四舍五入
if mod(n,2)==0
    n=n+1;%确定高斯卷积核的大小
end
h=fspecial('gaussian',[n,n],sigama);%创建卷积窗口
y=filter2(h,x);%filter2函数进行二维图像的卷积

%sift算法提取特征位置，并给出描述子
%影像获取
[Filename,Pathname,FilterIndex]=uigetfile({'*.jpg','C:\Users\admin\Desktop\徐方芳\数字摄影测量作业\SIFT算子'},'Select the input image');%uigetfile函数可以交互式的获取文件
%if FilterIndex
    pic_orig=imread([Pathname,Filename]);%imread函数用来读取原始标准影像
%else
   % return
%end
figure(1);
imshow(pic_orig);%imshow函数用来显示原始标准影像
title('原始标准影像');
 
%判断是否为彩色图像，是彩色则转换为灰度图像
[x,y,z]=size(pic_orig);
if(z~=1)
    pic_gray = rgb2gray(pic_orig);%rgb2gray将彩色图像转化为灰度图像
end
figure(2);
imshow(pic_gray);
title('灰度图像');
 
%构建高斯金字塔
[M,N]=size(pic_gray);
O=floor(log2(min(M,N)))-3;%确定高斯金字塔的组数(floor函数用来取整，round函数用来四舍五入)
S=3;%取高斯差分金字塔每组的层数为3
sigama0=1.6;%初始sigama0设为1.6
k=2^(1/S);
pic_gray0=imresize(pic_gray,2,'nearest');%先将原图像长、宽各扩展一倍
for i=1:O+1%遍历每一组
    if i==1
        pic_gray0=pic_gray0;
    else
        pic_gray0=imresize(gauss_pyr_img{i-1}{S+1},0.5,'nearest');%下一组第一层等于上一组倒数第三层直接降采样得到
    end
    for j=1:S+3%对每一组的每一层卷积
        sigama1=sigama0*2^(i-1);
        sigama=sigama1*k^(j-1);
        gauss_pyr_img{i}{j}=gauss(pic_gray0,sigama);
    end
end
 
%构建高斯差分金字塔
for i=1:O+1
    for j=1:S+2
        DoG_pyr_img{i}{j}=gauss_pyr_img{i}{j+1}-gauss_pyr_img{i}{j};
    end
end
 
%DoG空间极值探测并去除低对比度的边缘相应点
location=cell(size(DoG_pyr_img));%用来存储极值点
curvature_threshold=10.0;
curvature_threshold=(curvature_threshold+1)^2/curvature_threshold;%主曲率阈值
contrast_threshold=0.03;%对比度阈值
xx=[1 -2 1];
yy=xx';
xy=[-1 0 1;0 0 0;1 0 -1]/4;
for i=1:O+1
    [M,N]=size(DoG_pyr_img{i}{1});
    for j=2:S+1
        contrast_mask=abs(DoG_pyr_img{i}{j}(:,:))>=contrast_threshold;%对比度高于阈值的像素值为1，低于的为0
        location{i}{j-1}=zeros(M,N);
        for ii=2:M-1
            for jj=2:N-1
                if(contrast_mask(ii,jj)==1)%筛选出对比度高于阈值的点
                    tmp1=DoG_pyr_img{i}{j-1}((ii-1):(ii+1),(jj-1):(jj+1)); 
                    tmp2=DoG_pyr_img{i}{j}((ii-1):(ii+1),(jj-1):(jj+1));
                    tmp3=DoG_pyr_img{i}{j+1}((ii-1):(ii+1),(jj-1):(jj+1));
                    tmp=[tmp1;tmp2;tmp3];
                    center=tmp2(2,2);%中心点
                    if(center==max(tmp(:))||center==min(tmp(:)))
                        Dxx=sum(tmp2(2,1:3).*xx);
                        Dyy=sum(tmp2(1:3,2).*yy);
                        Dxy=sum(sum(tmp2(:,:).*xy));%计算极值处的Hessian矩阵
                        trH=Dxx+Dyy;
                        detH=Dxx*Dyy-(Dxy)^2;
                        curvature=(trH^2)/detH;%计算主曲率
                        if(curvature<curvature_threshold)%主曲率小于阈值
                            location{i}{j-1}(ii,jj)=255;
                        end
                    end
                end
            end
        end
    end
end
 
%求取特征点的主方向
length=cell(size(location));%用来存储关键点梯度大小
direction=cell(size(location));%用来存储关键点梯度方向
sigama0=1.6;
count=0;%设置一个计数器，用来确定计算以特征点为中心图像幅角和幅值的区域半径
hist=zeros(1,36);%存储邻域内梯度方向直方图
for i=1:O+1
    [M,N]=size(gauss_pyr_img{i}{1});
    for j=2:S+1
        count=count+1;
        sigama=sigama0*k^count;%确定区域半径的sigama
        length{i}{j-1}=zeros(M,N);
        direction{i}{j-1}=zeros(M,N);
        r=8;%区域半径设为8
        for ii=r+2:M-r-1
            for jj=r+2:N-r-1
                if(location{i}{j-1}(ii,jj)==255)
                    for iii=ii-r:ii+r
                        for jjj=jj-r:jj+r
                            m=sqrt((gauss_pyr_img{i}{j}(iii+1,jjj)-gauss_pyr_img{i}{j}(iii-1,jjj))^2+(gauss_pyr_img{i}{j}(iii,jjj+1)-gauss_pyr_img{i}{j}(iii,jjj-1))^2);
                            theta=atan((gauss_pyr_img{i}{j}(iii,jjj+1)-gauss_pyr_img{i}{j}(iii,jjj-1))/(gauss_pyr_img{i}{j}(iii+1,jjj)-gauss_pyr_img{i}{j}(iii-1,jjj)));
                            theta=theta/pi*180;%将弧度化为角度
                            if(theta<0)
                                theta=theta+360;
                            end
                            w=exp(-(iii^2+jjj^2)/(2*(1.5*sigama)^2));%生成邻域各像元的高斯权重
                            if(isnan(theta))
                                if(gauss_pyr_img{i}{j}(iii,jjj+1)-gauss_pyr_img{i}{j}(iii,jjj-1)>=0)
                                    theta=90;
                                else
                                    theta=270;
                                end
                            end
                            t=floor(theta/10)+1;
                            hist(t)=hist(t)+m*w;%将幅值*高斯权重加入对应的直方图中
                        end
                    end
                    for iiii=2:35
                        hist(iiii)=(hist(iiii-1)+hist(iiii)+hist(iiii+1))/3;%直方图的平滑处理
                    end
                    for iiii=2:35
                        hist(iiii)=(hist(iiii-1)+hist(iiii)+hist(iiii+1))/3;%第二次平滑处理
                    end
                    [u,v]=max(hist(:));
                    length{i}{j-1}(ii,jj)=u;%存储主方向上的幅值*高斯权重
                    direction{i}{j-1}(ii,jj)=(v-1)*10;%存储主方向
                end
            end
        end
    end
end
                    
%特征描述符的生成
sigama0=1.6;
count=0;
description=[];%用来存储描述子
index=0;%用来索引描述子
description_1=cell(size(location));%用来存储索引，通过索引找到description中对应的描述子
d=[];%存储邻域内每个像素梯度方向
l=[];%存储邻域内每个像素梯度幅值
f=zeros(1,8);%用来存放4*4邻域内8维描述子
description_2=[];%用来存放128维描述子
aaa=[];
for i=1:O+1
    [M,N]=size(gauss_pyr_img{i}{1});
    for j=2:S+1
        description_1{i}{j-1}=zeros(M,N);
        count=count+1;
        sigama=sigama0*k^count;
        %r=floor((3*sigama*sqrt(2)*5+1)/2);%确定描述子所需要的图像区域半径
        r=8;%设描述子所需要的图像区域半径
        for ii=r+2:M-r-1
            for jj=r+2:N-r-1
                if(length{i}{j-1}(ii,jj)~=0)
                    theta_1=direction{i}{j-1}(ii,jj);%该邻域的主方向
                    index=index+1;
                    description_2=[];
                    d=[];
                    l=[];
                    for iii=[ii-r:1:ii-1,ii+1:1:ii+r]
                        for jjj=[jj-r:1:jj-1,jj+1:1:jj+r]
                            m=sqrt((gauss_pyr_img{i}{j}(iii+1,jjj)-gauss_pyr_img{i}{j}(iii-1,jjj))^2+(gauss_pyr_img{i}{j}(iii,jjj+1)-gauss_pyr_img{i}{j}(iii,jjj-1))^2);
                            theta=atan((gauss_pyr_img{i}{j}(iii,jjj+1)-gauss_pyr_img{i}{j}(iii,jjj-1))/(gauss_pyr_img{i}{j}(iii+1,jjj)-gauss_pyr_img{i}{j}(iii-1,jjj)));
                            theta=theta/pi*180;%将弧度化为角度
                            if(theta<0)
                                theta=theta+360;
                            end
                            w=exp(-(iii^2+jjj^2)/(2*(1.5*sigama)^2));%生成邻域各像元的高斯权重
                            if(isnan(theta))
                                if(gauss_pyr_img{i}{j}(iii,jjj+1)-gauss_pyr_img{i}{j}(iii,jjj-1)>=0)
                                    theta=90;
                                else
                                    theta=270;
                                end
                            end
                            theta=theta+360-theta_1;%逆时针旋转至主方向
                            theta=mod(theta,360);%取余
                            d=[d,theta];
                            l=[l,m*w];
                        end
                    end
                    d=reshape(d,16,16);
                    l=reshape(l,16,16);%将一维数组变为二维矩阵
                    for r1=1:4
                        for c1=1:4
                            for iiii=1+(r1-1)*4:4*r1
                                for jjjj=1+(c1-1)*4:4*c1
                                    t=floor(d(iiii,jjjj)/45+1);%方向
                                    f(t)=f(t)+l(iiii,jjjj);
                                end
                            end
                            description_2=[description_2,f(:)];%得到一个128维的描述子
                        end
                    end
                    description_2=description_2./sqrt(sum(description_2(:)));%归一化处理
                    description=[description;description_2(:)];
                    description_1{i}{j-1}(ii,jj)=index;
                    aaa=[aaa;ii,jj];
                end
            end
        end
    end
end
description=reshape(description,[],128);%将描述子变为128维
 
%绘制特征点
figure(3)
imshow(pic_gray)
hold on
plot(aaa(:,1),aaa(:,2),'y+')
%description_1{i}{j}(ii,jj)中不为0的点即为特征点，其值为一个索引号，用这个索引号可以到description中找到相应的描述子