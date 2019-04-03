function J=Fjacobian(T,H,P,racount,order,flag) % racount����ȡƫ���Ĵ���,order�Ǳ�������������flagΪ�ж��������εı�־
freq_RPG=[22.24,23.04,23.84,25.44,26.24,27.84,31.40,51.26,52.28,53.86,54.94,56.66,57.30,58.00]';
N=size(freq_RPG,1)/2; % jacobian�����г���
M=size(T,1); % jacobian�����г���
J=zeros(N,M);
    for i=1:N % ��ͬ�е��������ƫ��
        for j=1:M % �Բ�ͬ�ı�����ƫ��
            scale=T(j)/order; % �����������Χ
            T_cache=T; % ������ʱ�洢�¶ȱ���
            deriv=zeros(racount,1); % ���ڴ������ƫ��֮��
            for count=1:racount % �������ԳƲ�������ƫ��
                fluct=rand*scale; % ��ǰ�����������ֵ
                T_cache(j)=T(j)+fluct;
                f1=forward_mode(P,T_cache,H,freq_RPG(i+N));
                T_cache(j)=T(j)-fluct;
                f2=forward_mode(P,T_cache,H,freq_RPG(i+N));
                deriv(count)=(f1-f2)/fluct/2;
            end
            J(i,j)=sum(deriv)/racount;
        end
    end