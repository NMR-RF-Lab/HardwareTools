%[text] Initialized basic variables
f1H = 123.2030E6; w1H = 2*pi*f1H;
f31P = 49.8719E6; w31P = 2*pi*f31P;
%[text] First, I soldered on two different sets of capacitors & measured the resonance with a double-loop probe.
C1 = 91E-12; f1 = 42.7650E6;
C2 = 43E-12; f2 = 59.7535E6;
%[text] I then used the equation for a line (y=mx+b) and calculated what capacitance needed to tune the coil to 49.8719MHz. 
m = (f2 - f1)/(C2 - C1);
b = f1 - m*C1;
x = (f31P - b)/m %[output:161da1fe]
%[text] Next, using Meyerspeers' equations ([An improved trap design for decoupling multinuclear RF coils - 2014 - MRM](https://onlinelibrary.wiley.com/doi/10.1002/mrm.24931)), we can calculate the LCC values.
% Initialize functions
Ltr = @(C_coil, w_H, w_L)((1/C_coil)*(4/(w_H^2 - w_L^2)));
Ltr_sym = sym(Ltr) %[output:5ead2dbe]
Cs1 = @(C_coil, w_H, w_L, L_tr)((w_H^2 + w_L^2)/((L_tr*(w_L*w_H)^2)+(w_H^2 - w_L^2)/C_coil)*(1/2 + sqrt(1/4 - ((L_tr*(w_L*w_H)^2)+(w_H^2 - w_L^2)/C_coil)/(L_tr*((w_H^2 + w_L^2)^2)))));
Cs1_sym = sym(Cs1) %[output:981c67d6]
Cs2 = @(C_coil, w_H, w_L, L_tr)((w_H^2 + w_L^2)/((L_tr*(w_L*w_H)^2)+(w_H^2 - w_L^2)/C_coil)*(1/2 - sqrt(1/4 - ((L_tr*(w_L*w_H)^2)+(w_H^2 - w_L^2)/C_coil)/(L_tr*((w_H^2 + w_L^2)^2)))));
Cs2_sym = sym(Cs2) %[output:7906a96c]
Cp0 = @(C_s, w_H, L_tr)(1/(L_tr*w_H^2 - 1/C_s));
Cp_sym = sym(Cp0) %[output:2dec8c49]
% Plug in values
L = Ltr(x, w1H, w31P) %[output:5294b2cb]
%[text] I will then determine parameters to design the inductor, based on given limitations
u0 = 4*pi*10^-7; % permeability of free space
r = 2E-3 % radius, m (largest we would want to go based off size of trap circuit %[output:1508cc20]
l = 7E-3 % length, m (longest we would want to go based off size of trap circuit) %[output:0652ea84]
d_awg = 20; % diameter, awg
d_m = (0.127*92^((36-d_awg)/39))/1000;
N_max = floor(l/d_m) % number of turns, based on diameter of wire & length of inductor %[output:6a481e4b]
N = ceil(sqrt(L*l/(u0*pi*r^2))) %[output:675bfbfa]
%[text] Then, I will calculate the theoretical inductance of the solenoid
L_true = (u0*pi*(r^2)*(N^2))/l %[output:83323bb3]
Cs = Cs1(x, w1H, w31P, L_true)*10^12 %[output:38d607d5]
Cp = Cp0(Cs, w1H, L_true)*10^12 %[output:8815f8ce]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":40}
%---
%[output:161da1fe]
%   data: {"dataType":"not_yet_implemented_variable","outputData":{"columns":"1","name":"x","rows":"1","value":"7.0920e-11"},"version":0}
%---
%[output:5ead2dbe]
%   data: {"dataType":"symbolic","outputData":{"name":"Ltr_sym","value":"\\frac{4}{C_{\\textrm{coil}} \\,{\\left({w_H }^2 -{w_L }^2 \\right)}}"}}
%---
%[output:981c67d6]
%   data: {"dataType":"symbolic","outputData":{"name":"Cs1_sym","value":"\\frac{{\\left({w_H }^2 +{w_L }^2 \\right)}\\,{\\left(\\sqrt{0.2500-\\frac{\\frac{{w_H }^2 -{w_L }^2 }{C_{\\textrm{coil}} }+L_{\\textrm{tr}} \\,{w_H }^2 \\,{w_L }^2 }{L_{\\textrm{tr}} \\,{{\\left({w_H }^2 +{w_L }^2 \\right)}}^2 }}+0.5000\\right)}}{\\frac{{w_H }^2 -{w_L }^2 }{C_{\\textrm{coil}} }+L_{\\textrm{tr}} \\,{w_H }^2 \\,{w_L }^2 }"}}
%---
%[output:7906a96c]
%   data: {"dataType":"symbolic","outputData":{"name":"Cs2_sym","value":"-\\frac{{\\left({w_H }^2 +{w_L }^2 \\right)}\\,{\\left(\\sqrt{0.2500-\\frac{\\frac{{w_H }^2 -{w_L }^2 }{C_{\\textrm{coil}} }+L_{\\textrm{tr}} \\,{w_H }^2 \\,{w_L }^2 }{L_{\\textrm{tr}} \\,{{\\left({w_H }^2 +{w_L }^2 \\right)}}^2 }}-0.5000\\right)}}{\\frac{{w_H }^2 -{w_L }^2 }{C_{\\textrm{coil}} }+L_{\\textrm{tr}} \\,{w_H }^2 \\,{w_L }^2 }"}}
%---
%[output:2dec8c49]
%   data: {"dataType":"symbolic","outputData":{"name":"Cp_sym","value":"\\frac{1}{L_{\\textrm{tr}} \\,{w_H }^2 -\\frac{1}{C_s }}"}}
%---
%[output:5294b2cb]
%   data: {"dataType":"not_yet_implemented_variable","outputData":{"columns":"1","name":"L","rows":"1","value":"1.1257e-07"},"version":0}
%---
%[output:1508cc20]
%   data: {"dataType":"not_yet_implemented_variable","outputData":{"columns":"1","name":"r","rows":"1","value":"0.0020"},"version":0}
%---
%[output:0652ea84]
%   data: {"dataType":"not_yet_implemented_variable","outputData":{"columns":"1","name":"l","rows":"1","value":"0.0070"},"version":0}
%---
%[output:6a481e4b]
%   data: {"dataType":"not_yet_implemented_variable","outputData":{"columns":"1","name":"N_max","rows":"1","value":"8"},"version":0}
%---
%[output:675bfbfa]
%   data: {"dataType":"not_yet_implemented_variable","outputData":{"columns":"1","name":"N","rows":"1","value":"8"},"version":0}
%---
%[output:83323bb3]
%   data: {"dataType":"not_yet_implemented_variable","outputData":{"columns":"1","name":"L_true","rows":"1","value":"1.4438e-07"},"version":0}
%---
%[output:38d607d5]
%   data: {"dataType":"not_yet_implemented_variable","outputData":{"columns":"1","name":"Cs","rows":"1","value":"29.9682"},"version":0}
%---
%[output:8815f8ce]
%   data: {"dataType":"not_yet_implemented_variable","outputData":{"columns":"1","name":"Cp","rows":"1","value":"11.5584"},"version":0}
%---
