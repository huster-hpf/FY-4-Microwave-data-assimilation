%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算平静海面介电常数--KS模型%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%李炎，2013.4.16

%%% 输入参数：
%%%  sss salinity [psu]
%%% 
%%% 输出参数：
%%% dielectric_constant海水介电常数

function dielectric_constant = Sea_Dielectric_Constant(SSS,SST)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%介电常数计算%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SSS2 = SSS*SSS;
SSS3 = SSS2*SSS;
T0 = 273.5; 
SSTC = SST-T0;
SSTC2 = SSTC*SSTC;
SSTC3 = SSTC2*SSTC;
SSTminus25 = SSTC-25;
SSTminus25sq = SSTminus25*SSTminus25;


%Klein and Swift model 系数
s = [0.182521 -0.00146192 2.09324e-5 -1.28205e-7 0.02033 0.0001266 2.464e-6 1.849e-5 -2.551e-7 2.551e-8];
t = [1.78e-11 -6.086e-13 1.104e-14 -8.111e-17 1.0 2.282e-5 -7.638e-4 -7.760e-6 1.105e-8];
m = [87.134 -0.1949 -0.01276 0.0002491 1.0 1.613e-5 -0.003656 3.21e-5 -4.232e-7];

%介电常数
sigma=SSS * (s(1) + s(2)*SSS + s(3)*SSS2 + s(4)*SSS3) * exp(SSTminus25 * (s(5)-s(6)*SSTminus25+s(7)*SSTminus25sq-SSS * (s(8)-s(9)*SSTminus25+s(10)*SSTminus25sq)));
tau = (t(1) + t(2)*SSTC + t(3)*SSTC2 +t(4)*SSTC3) * (t(5) + t(6)*SSTC*SSS + t(7)*SSS + t(8)*SSS2 + t(9)*SSS3);
epsilons = (m(1) + m(2)*SSTC + m(3)*SSTC2 +m(4)*SSTC3) * (m(5) + m(6)*SSTC*SSS + m(7)*SSS + m(8)*SSS2 + m(9)*SSS3);

denom1 = 1 + 1i*8.878e9*tau;
denom2 = 8.878e9 * 8.85419e-12;
epsilon = 4.9 + (epsilons - 4.9)/denom1 - 1i*sigma/denom2;
dielectric_constant=epsilon;