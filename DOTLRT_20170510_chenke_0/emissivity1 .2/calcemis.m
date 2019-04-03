function [emissstokes,reflectstokes] = calcemis(freq_ghz,zenith,azimuth,surftype,skin,wind,salinity)
%CALCEMIS Based on NWPSAF RTTOV rttov_calcemis_mw.F90
%   For sea surface, FASTEM5 is called to calculate the emissivity and
%   reflectivity
%   For land surface, some extra codes are used.
%   stokes: v,h,3,4
%   
t = skin(1);
%salinity=35; % Not sure, but I haven't find the evaluation line of this variable.
fastem=skin(2:6);
u=wind(1);
v=wind(2);
Wind_Speed=(u^2+v^2)^0.5;
wind_angle=angle(u+v*1i)*180/pi;
sinzen=sin(zenith*pi/180);
coszen=cos(zenith*pi/180);

if wind_angle<0
    wind_angle=wind_angle+360;
end
Rel_Azimuth=wind_angle-azimuth;

if surftype==1 % Which means sea surface,then fastem-5 is applied.
    [emissstokes,reflectstokes]=fastem_5(freq_ghz,zenith,...
    t,salinity,Wind_Speed,Rel_Azimuth);
else %Land or ice? RTTOV/rttov_calcemis_mw doesn't distinguish them. Thus a
    % series of unified coefficients are introduced. See RTTOV user guide
    % p51
      perm_static         = fastem(1);
      perm_infinite       = fastem(2);
      freqr               = fastem(3);
      small_rough         = fastem(4);
      large_rough         = fastem(5);
      
%Simple Debye + Fresnel model gives reflectivities
      fen = freq_ghz / freqr;
      fen_sq              = fen * fen;
      den1 = 1.0 + fen_sq;
      perm_Real           = (perm_static + perm_infinite * fen_sq) / den1;
      perm_imag           = fen * (perm_static - perm_infinite) / den1;
      permittivity        = perm_Real+perm_imag*1j;
      perm1               = sqrt(permittivity - sinzen^2);
      perm2               = permittivity * coszen;
      rhth = (coszen - perm1) / (coszen + perm1);
      rvth = (perm2 - perm1) / (perm2 + perm1);
      fresnel_v_Real      = real(rvth);
      fresnel_v_imag      = imag(rvth);
      fresnel_v           = fresnel_v_Real * fresnel_v_Real + fresnel_v_imag * fresnel_v_imag;
      fresnel_h_Real      = real(rhth);
      fresnel_h_imag      = imag(rhth);
      fresnel_h           = fresnel_h_Real * fresnel_h_Real + fresnel_h_imag * fresnel_h_imag;
%Small scale roughness correction
      delta               = 4.0 * pi * (30/freq_ghz) * 0.1* small_rough;
      delta2              = delta * delta;
      small_rough_cor     = exp( - delta2 * coszen^2);
%Large scale roughness correction
      qdepol              = 0.35 - 0.35 * exp( - 0.60 * freq_ghz * large_rough * large_rough);
      emissfactor_v       = 1.0 - fresnel_v * small_rough_cor;
      emissfactor_h       = 1.0 - fresnel_h * small_rough_cor;
      emissfactor         = emissfactor_h - emissfactor_v;
      emissstokes(1)   = emissfactor_v + qdepol * emissfactor;
      emissstokes(2)   = emissfactor_h - qdepol * emissfactor;
      emissstokes(3)   = 0.0;
      emissstokes(4)   = 0.0;
      reflectstokes = 1.0 - emissstokes(:);
    
end


end

