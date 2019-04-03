function [Emissivity, Reflectivity] = fastem_5( Frequency,Zenith_Angle,...
    Temperature,Salinity,Wind_Speed,Rel_Azimuth) %Rel_Azimuth relative Azimuth angle
%FASTEM_5 Based on the Fortran code rttov_fastem5.F90 supplied by 
%         EUMETSAT Satellite Application Facility on
%         Numerical Weather Prediction (NWP SAF). The rttov_fastem5.F90
%         file can be found in rttov install source code package.


%  History:
%  1.0      2016/3/23     Translated from the NWP SAF fortran version(Li Gongwei)

%  SUBROUTINE rttov_fastem5( fastem_version, &         % Input
%                               Frequency   , &         % Input
%                               Zenith_Angle, &         % Input
%                               Temperature , &         % Input
%                               Salinity    , &         % Input
%                               Wind_Speed  , &         % Input
%                               Emissivity  , &         % Output
%                               Reflectivity, &         % Output
%                               Transmittance,&         % Input, may not be used
%                               Rel_Azimuth  ,&         % Input, may not be used
%                               Supply_Foam_Fraction, & % Optional input
%                               Foam_Fraction)          % Optional input
%  Description:
%  To compute FASTEM-5 emissivities and reflectivities.Detailed explanation goes here
Emissivity=zeros(1,4);
Reflectivity=zeros(1,4);

load_FASTEM5_coefs;
e0 = e0_5;
Lcoef = Lcoef5;
t_c = t_c5;
cos_z = cos( Zenith_Angle*DEGREES_TO_RADIANS );

%   TYPE :: PermittivityVariables_type
% %    PRIVATE
%     REAL(fp) :: t, t_sq, t_cu                   % Temperature in degC
%     REAL(fp) :: f1, f2, del1, del2, tau1_k, tau2_k, es_k, e1_k
%     REAL(fp) :: ces, ctau1, ctau2, ce1, delta, beta, sigma, S
%   END TYPE PermittivityVariables_type
%   TYPE(PermittivityVariables_type) :: iVar
t = Temperature-273.15;
t_sq = t^2;
t_cu = t^3;
S = Salinity;

einf = A_COEF(1) + A_COEF(2)*t;
es = A_COEF(3) + A_COEF(4)*t + A_COEF(5)*t_sq + A_COEF(6)*t_cu;
e1 = A_COEF(10) + A_COEF(11)*t + A_COEF(12)*t_sq;
tau1 = A_COEF(16) + A_COEF(17)*t + A_COEF(18)*t_sq + A_COEF(19)*t_cu;
tau2 = A_COEF(23) + A_COEF(24)*t + A_COEF(25)*t_sq + A_COEF(26)*t_cu;

es_k = es;
e1_k = e1;
tau1_k = tau1;
tau2_k = tau2;
perm_imag = 0;

if(S > 0 )
    delta = 25.0 - t;
    beta  = A_COEF(30) +A_COEF(31)*delta +A_COEF(32)*delta^2+...
    S*(A_COEF(33) +A_COEF(34)*delta +A_COEF(35)*delta^2);
    sigma25 = S*(A_COEF(36) +A_COEF(37)*S +A_COEF(38)*S^2+...
    A_COEF(39)*S^3);
    sigma = sigma25*exp(-delta*beta);
    
    ces = 1 + S*(A_COEF(7) + A_COEF(8)*S + A_COEF(9)*t );
    ce1 = 1 + S*(A_COEF(13) + A_COEF(14)*S +A_COEF(15)*t );
    ctau1 = 1 + S*(A_COEF(20) +A_COEF(21)*t + A_COEF(22)*t_sq);
    ctau2 = 1 + S*(A_COEF(27) + A_COEF(28)*t + A_COEF(29)*S^2 );
    es = es_k * ces;
    e1 = e1_k * ce1;
    tau1 = tau1_k * ctau1;
    tau2 = tau2_k * ctau2;
    perm_imag = -sigma/(2*pi*e0*Frequency);
end

%Define two relaxation frequencies, f1 and f2
f1 = Frequency*tau1;
f2 = Frequency*tau2;
del1 = es - e1;
del2 = e1 - einf;

% perm_Real = einf + del1/(1 + f1^2) + del2/(1 + f2^2);
% perm_imag = -perm_imag + del1*f1/(1 + f1^2)+ del2*f2/(1 + f2^2);
% permittivity = perm_Real-perm_imag*1j;
permittivity = einf + del1/(1+1j*f1)+del2/(1+1j*f2)+1j*perm_imag; % Inconsistent with fastem4
% permittivity = real(permittivity)+1j*imag(permittivity);
%   TYPE :: FresnelVariables_type
% %    PRIVATE
%     % The intermediate terms
%     COMPLEX(fp) :: z1, z2
%     % The real and imaginary components
%     REAL(fp)    :: rzRv,izRv  % Vertical
%     REAL(fp)    :: rzRh,izRh  % Horizontal
%   END TYPE FresnelVariables_type 
% TYPE(FresnelVariables_type) :: frVar
% ---------------------------------------------------------
% Compute Fresnel reflectance code, adopted from Masahiro Kazumori, JMA
% Compute the complex reflectivity components
z1 = (permittivity - 1 + (cos_z*cos_z))^0.5;
z2 = permittivity * cos_z;
zRh = (cos_z  -z1) / (cos_z  +z1);
zRv = (z2-z1) / (z2+z1);



% The square of the vertical abs value
rzRv = real(zRv);
izRv = imag(zRv);
Rv_Fresnel = rzRv^2 + izRv^2;

% The square of the horizontal abs value
rzRh = real(zRh);
izRh = imag(zRh);
Rh_Fresnel = rzRh^2 + izRh^2;

% Apply small-scale correction
% --------------------------------
% Note from Steve English: 'windspeed' is restricted to be between min_wind and
% max_wind here. After this section the unrestricted 'Wind_Speed' is used. This
% is done intentionally.
windspeed = Wind_Speed;
if( windspeed < min_wind ) 
    windspeed = min_wind;
end
if( windspeed > max_wind ) 
    windspeed = max_wind;
end

freq_S = Frequency;
if( freq_S < min_f ) 
    freq_S = min_f;
end
if( freq_S > max_f ) 
    freq_S = max_f;
end

scor = Scoef(1) *windspeed*freq_S +Scoef(2) *windspeed*freq_S^2 +...
    Scoef(3) *windspeed^2* freq_S +Scoef(4) *windspeed^2* freq_S^2 +...
    Scoef(5) *windspeed^2 /freq_S +Scoef(6) *windspeed^2 /freq_S^2 +...
    Scoef(7) *windspeed + Scoef(8) *windspeed^2;

small_corr = exp(-scor*cos_z*cos_z );
RvS = Rv_Fresnel * small_corr;
RhS = Rh_Fresnel * small_corr;


% Large Scale Correction Calculation
% ----------------------------------
seczen = 1/cos_z;
% compute fitting coefficients for a given Frequency
zc =zeros(1,12);

for j = 1:12
    zc(j) = Lcoef(j*3-2) + Lcoef(j*3-1)*Frequency + Lcoef(j*3)*Frequency^2;
end

RvL = zc(1) + zc(2)*seczen + zc(3)*seczen^2 + zc(4)*Wind_Speed +...
    zc(5)*Wind_Speed^2 + zc(6)*Wind_Speed*seczen;
RhL = zc(7) + zc(8)*seczen + zc(9)*seczen^2 + zc(10)*Wind_Speed +...
    zc(11)*Wind_Speed^2 + zc(12)*Wind_Speed*seczen;

% Monahan et al., 1986 without surface stability term
Foam_Cover = 1.95E-05 * Wind_Speed ^ 2.55;


  % The foam vertical and horizontal reflectanc codes, adopted from Masahiro Kazumori, JMA
  % ----------------------------------
    Foam_Rv = FR_COEFF(1);
    Fh = 1 + Zenith_Angle*(FR_COEFF(2) +  Zenith_Angle*(FR_COEFF(3) +...
        Zenith_Angle*FR_COEFF(4)));
    Foam_Rh = 1 + FR_COEFF(5)*Fh;

    % Added Frequency dependence derived from Stogry model
    Foam_ref = 0.4 * exp(-0.05*Frequency );
    Foam_Rv = Foam_Rv * Foam_ref;
    Foam_Rh = Foam_Rh * Foam_ref;

    Ev = (1-Foam_Cover)*(1 - RvS + RvL) + Foam_Cover*(1-Foam_Rv);
    Eh = (1-Foam_Cover)*(1 - RhS + RhL) + Foam_Cover*(1-Foam_Rh);

    Emissivity(1) = Ev;
    Emissivity(2) = Eh;


    
    % Transmittance are not considered.
    % -------------------------------------------
    zreflmod_v = 1;
    zreflmod_h = 1; 
    
    
 % azimuthal component
  % --------------------------------
    Azimuth_Emi = zeros(1,4);
    if  abs(Rel_Azimuth) <= 360.0 
        % M.Liu      azimuth model function
        Fre_C = 0;
        if (Frequency >= min_f || Frequency <= max_f ) 
          for i = 1: 8
            if (Frequency >= x(i) && Frequency < x(i+1)) 
              Fre_C = y(i) + (y(i+1)-y(i))/(x(i+1)-x(i))*(Frequency-x(i));
            end
          end
        end

        phi = Rel_Azimuth * DEGREES_TO_RADIANS;
        wind10 = Wind_Speed;
        for m = 1:3
          L = 10*(m-1);
          ac = b_coef(L+1) +b_coef(L+2)*Frequency +b_coef(L+3)*seczen+...
              b_coef(L+4)*seczen*Frequency+...
              b_coef(L+5)*wind10 +b_coef(L+6)*wind10*Frequency +b_coef(L+7)*wind10^2+...
              b_coef(L+8)*Frequency*wind10^2 +b_coef(L+9)*wind10*seczen+...
              b_coef(L+10)*wind10*seczen*Frequency;
          Azimuth_Emi(1) = Azimuth_Emi(1) + ac*cos(m*phi);

          L = 10*(m-1) + 30;
          ac = b_coef(L+1) +b_coef(L+2)*Frequency +b_coef(L+3)*seczen+...
              b_coef(L+4)*seczen*Frequency+...
              b_coef(L+5)*wind10 +b_coef(L+6)*wind10*Frequency +b_coef(L+7)*wind10^2+...
              b_coef(L+8)*Frequency*wind10^2 +b_coef(L+9)*wind10*seczen+...
              b_coef(L+10)*wind10*seczen*Frequency;
          Azimuth_Emi(2) = Azimuth_Emi(2) + ac*cos(m*phi);

          L = 10*(m-1) + 60;
          sc = b_coef(L+1) +b_coef(L+2)*Frequency +b_coef(L+3)*seczen+...
              b_coef(L+4)*seczen*Frequency+...
              b_coef(L+5)*wind10 +b_coef(L+6)*wind10*Frequency +b_coef(L+7)*wind10^2+...
              b_coef(L+8)*Frequency*wind10^2 +b_coef(L+9)*wind10*seczen+...
              b_coef(L+10)*wind10*seczen*Frequency;
          Azimuth_Emi(3) = Azimuth_Emi(3) + sc*sin(m*phi);

          L = 10*(m-1) + 90;
          sc = b_coef(L+1) +b_coef(L+2)*Frequency +b_coef(L+3)*seczen+...
              b_coef(L+4)*seczen*Frequency+...
              b_coef(L+5)*wind10 +b_coef(L+6)*wind10*Frequency +b_coef(L+7)*wind10^2+...
              b_coef(L+8)*Frequency*wind10^2 +b_coef(L+9)*wind10*seczen+...
              b_coef(L+10)*wind10*seczen*Frequency;
          Azimuth_Emi(4) = Azimuth_Emi(4) + sc*sin(m*phi);
        end

        Azimuth_Emi = Azimuth_Emi * Fre_C;
    end
    Emissivity(1) = Emissivity(1) + Azimuth_Emi(1);
    Emissivity(2) = Emissivity(2) + Azimuth_Emi(2);
    Emissivity(3) = Azimuth_Emi(3);
    Emissivity(4) = Azimuth_Emi(4);
    Reflectivity(1)  = zreflmod_v * (1-Emissivity(1));
    Reflectivity(2)  = zreflmod_h * (1-Emissivity(2));
    % Reflectivities not computed for 3rd or 4th elements of Stokes vector, 
    % as never used subsequently, as atmospheric source term = zero.
    Reflectivity(3:4)  = 0;
    
    









































end

