      function [e,rho] = vapor(tk,rh,ice)
  
% Computes vapor pressure and vapor density from temperature 
% and relative humidity.

% Inputs passed as arguments: 
%      tk   = temperature (k)
%      rh   = relative humidity (fraction)
% Inputs passed through common: 
%      rvap = gas constant for water vapor (mb*(m**3)/g/k)
%      ice  = switch to calculate saturation vapor pressure over
%             water only (0) or water and ice, depending on tk (1)
% Outputs: 
%      e    = vapor pressure (mb)
%      rho  = vapor density (g/m3)

% Assign values to physical constants, including the Universal Gas Constant 
% (R,in j/mol/K), molecular weights of dry air (mdry,in g/mol) and water
% vapor (mvap,in g/mol), and the kelvin-to-celsius conversion value (tk2tc) 
% select saturation vapor pressure calculation over water (ice=0) or ice(1) 
  
      R =  8.314510;
      mdry = 28.96415;
      mvap = 18.01528;
      tk2tc = 273.16;
      
% Compute gas constant for water vapor (Rvap,in mb*m**3/g/K) and the
% ratio of molecular weights, water vapor : dry air (epsilon).
  
      rvap    = 0.01 * R/mvap;
      epsilon = mvap/mdry;
  
% Compute saturation vapor pressure (es,in mb) over water or ice at
% temperature tk (kelvins), using the goff-gratch formulation (list,1963).
  
% for Water...
  
      if tk > 263.16 | ice == 0 
        y = 373.16 / tk;
        es = -7.90298 * (y-1.) + 5.02808 * log10 (y) - ...
            1.3816e-7 * (10 ^ (11.344 * (1. - (1./ y))) - 1.) + ...
            8.1328e-3 * (10.^ (-3.49149 * (y - 1.)) - 1.) + ...
            log10 (1013.246);
  
% for ice...
  
      else
        y = 273.16 / tk;
        es = -9.09718 * (y - 1.) - 3.56654 * log10 (y) + ...
             .876793 * (1.- (1./ y)) + alog10 (6.1071);
      end
  
      es = 10. ^ es;
  
% Compute vapor pressure and vapor density.
% The vapor density conversion follows the ideal gas law: 
% vapor pressure = vapor density * rvapor * tk
  
      e = rh * es;
      rho = e / (rvap * tk);
  