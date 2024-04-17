%%
%�ӳ�ʱ���ʱ�䴰�ڼ���

function [Smean,Sdeltmean,Scor,tau,tw]=CCMethod(data,max_d)
% �������������ӳ�ʱ��tau��ʱ�䴰��tw
% data������ʱ������
% max_d�����ʱ���ӳ�
% Smean��Sdeltmean,ScorΪ����ֵ
% tau������õ����ӳ�ʱ��
% tw��ʱ�䴰��
N=length(data);
%ʱ�����еĳ���
Smean=zeros(1,max_d);
%��ʼ������
Scmean=zeros(1,max_d);
Scor=zeros(1,max_d);
sigma=std(data);
%�������еı�׼��
% ����Smean,Sdeltmean,Scor
for t=1:max_d
    S=zeros(4,4);
    Sdelt=zeros(1,4);
    for m=2:5
        for j=1:4
            r=sigma*j/2;
            Xdt=disjoint(data,t);
            % ��ʱ������data�ֽ��t�����ཻ��ʱ������
            s=0;
           for tau=1:t
                N_t=floor(N/t);
                % �ֳɵ������г���
                Y=Xdt(:,tau);
                % ÿ��������
                %����C(1,N/t,r,t),�൱�ڵ���Cs1(tau)=correlation_integral1(Y,r)            
                Cs1(tau)=0;
                for ii=1:N_t-1
                    for jj=ii+1:N_t
                        d1=abs(Y(ii)-Y(jj));
                        % ����״̬�ռ���ÿ����֮��ľ���,ȡ�����
                        if r>d1
                            Cs1(tau)=Cs1(tau)+1;            
                        end
                    end
                end
                Cs1(tau)=2*Cs1(tau)/(N_t*(N_t-1));
              
                Z=reconstitution(Y,m,1);
                % ��ռ��ع�
                M=N_t-(m-1); 
                Cs(tau)=correlation_integral(Z,M,r);
                % ����C(m,N/t,r,t)
                s=s+(Cs(tau)-Cs1(tau)^m);
                % ��t������ص�ʱ���������
           end            
           S(m-1,j)=s/tau;            
        end
        Sdelt(m-1)=max(S(m-1,:))-min(S(m-1,:));
        % ��������
    end
    Smean(t)=mean(mean(S));
    % ����ƽ��ֵ
    Sdeltmean(t)=mean(Sdelt);
    % ����ƽ��ֵ
    Scor(t)=abs(Smean(t))+Sdeltmean(t);
end
% Ѱ��ʱ���ӳ�tau����Sdeltmean��һ����Сֵ���Ӧ��t
for i=2:length(Sdeltmean)-1
    if Sdeltmean(i)<Sdeltmean(i-1)&Sdeltmean(i)<Sdeltmean(i+1)
        tau=i;
        break;
    end
end
% Ѱ��ʱ�䴰��tw����Scor��Сֵ��Ӧ��t
for i=1:length(Scor)
    if Scor(i)==min(Scor)
        tw=i;
        break;
    end
end
%%
%ʱ�����зֽ�
function Data=disjoint(data,t)
% �˺������ڽ�ʱ�����зֽ��t�����ཻ��ʱ������
% data:����ʱ������
% t:�ӳ٣�Ҳ�ǲ��ཻʱ�����еĸ���
% Data:���طֽ���t�����ཻ��ʱ������
N=length(data);
%data�ĳ���
for i=1:t
    for j=1:(N/t)
        Data(j,i)=data(i+(j-1)*t);
    end
end
%%
%��ռ��ع�
function Data=reconstitution(data,m,tau)
%�ú��������ع���ռ�
% m:Ƕ��ռ�ά��
% tau:ʱ���ӳ�
% data:����ʱ������
% Data:���,��m*nά����
%m=tw/tau+1
N=length(data); 
% NΪʱ�����г���
M=N-(m-1)*tau; 
%��ռ��е�ĸ���
Data=zeros(m,M);
for j=1:M
  for i=1:m
  %��ռ��ع�
    Data(i,j)=data((i-1)*tau+j);
  end
end
%�������ּ���
function C_I=correlation_integral(X,M,r)
%�ú������������������
%C_I:�������ֵķ���ֵ
%X:�ع�����ռ�ʸ������һ��m*M�ľ���
%M::M���ع���mά��ռ��е��ܵ���
%r:Heaviside �����е������뾶
sum_H=0;
for i=1:M-1
    for j=i+1:M
        d=norm((X(:,i)-X(:,j)),inf);
        %������ռ���ÿ����֮��ľ��룬����NORM(V,inf) = max(abs(V)).
        if r>d    
        %sita=heaviside(r,d);%����Heaviside ����ֵ֮n
           sum_H=sum_H+1;
        end
    end
end
C_I=2*sum_H/(M*(M-1));%�������ֵ�ֵ