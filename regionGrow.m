function J=regionGrow(I)
if isinteger(I)
    I=im2double(I);
end
figure 
imshow(I)
[M,N]=size(I);
[y,x]=getpts;%单击取点后，按enter结束
x1=round(x);
y1=round(y);
seed=I(x1,y1);
J=zeros(M,N);
J(x1,y1)=1;
sum=seed;
suit=1;%点的个数
count=1;
threshold=0.15;
while count>0
    s=0;
    count=0;
    for i=1:M
        for j=1:N
            if J(i,j)==1
                if (i-1)>0&(i+1)<(M+1)&(j-1)>0&(j+1)<(N+1)
                    for u=-1:1
                        for v=-1:1
                            if J(i+u,j+v)==0&abs(I(i+u,j+v)-seed)<=threshold&1/(1+1/15*abs(I(i+u,j+v)-seed))>0.8
                                J(i+u,j+v)=1;
                                count=count+1;
                                s=s+I(i+u,j+v);
                            end
                        end
                    end
                end
            end
        end
    end
    suit=suit+count;
    sum=sum+s;
    seed=sum/suit;
end