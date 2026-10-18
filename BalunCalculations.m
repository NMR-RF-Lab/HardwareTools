clear; clc; close all;

%% Initialize Parameters
% Initialize data
gamma  = [  42.5774781,      17.2351242,  11.2621906].*10^6;

% Ask about first nuclei
Qn1 = questdlg('Select the higher frequency nuclei:', ...
    'Higher Nuclei', ...
    'Hydrogen-1', 'Phosphorus-31', 'Hydrogen-1');
switch Qn1
    case 'Hydrogen-1'
        % Set gyromagnetic ratio
        y(2) = gamma(1);

        % Ask about second nuclei
        Qn2 = questdlg('Select the lower frequency nuclei:', ...
            'Lower Nuclei', ...
            'Phosphorus-31', 'Sodium-23', 'Phosphorus-31');

    case 'Phosphorus-31'
        % Set first gyromagnetic ratio
        y(2) = gamma(2);

        % Ask about second nuclei
        Qn2 = questdlg('Select the lower frequency nuclei:', ...
            'Lower Nuclei', ...
            'Sodium-23', 'Sodium-23');   
end

% Set option for second nuclei
switch Qn2
    case 'Phosphorus-31'
        % Set gyromagnetic ratio
        y(1) = gamma(2);

    case 'Sodium-23'
        % Set gyromagnetic ratio
        y(1) = gamma(3);
end
y = y.';

% Ask about magnetic field
opts.Interpreter = 'tex';
Qb0 = inputdlg('Enter the magnetic field strength:', 'B0', [1 40], {'2.89362'}, opts);
B0 = str2double(Qb0{1});

% Calculate frequencies based on user input
f0 = y.*B0; % frequency, Hz
w0 = f0.*2*pi; % frequency, rad/s

% Calculate limits for each section
x = [ceil((f0*10^-6) - 5), floor((f0*10^-6) + 5)];
w = (x(1,1):0.03:x(2,2)).*(2*pi*1E6);

%% Balun inductor
% Parameters
N = 10; % number of turns
l = 25/1000; % length, m
r = 5.5/1000; % radius, m


% Calculate inductance
Lb = Solenoid(r, N, l);

% Ask about experimental inductance
Qel = questdlg('Was the balun inductance measured experimentally?', ...
    '', ...
    'Yes', 'No', 'Yes');
switch Qel
    case 'Yes'
        Lb = inputdlg('Enter the experimental inductance (nH):', 'Lb', [1 50], {'308'}, opts);
        Lb = str2double(Lb{1})*10^-9;
end

% Capacitance to tune each frequency
Cb = 1./(Lb.*(w0.^2));

% Reactance for each capacitance
Xb_ST = XLC(Lb, Cb, w);

%% Plot
% Initialize figure
figure; 
t = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
tAx = axes(t,'XTick',[],'YTick',[],'Box','off'); 
tAx.Layout.TileSpan = [1 2];

% Create first plot
Ax1 = axes(t); Ax1.Layout.Tile = 1;
plot(Ax1, w./(2*pi*1E6), Xb_ST(1,:));
xline(Ax1, x(1,2), ':'); 
xline(Ax1, f0(1).*1E-6, '--'); 
Ax1.Box = 'off'; 
xlim(Ax1, x(1,:));

% Create second plot
Ax2 = axes(t); Ax2.Layout.Tile = 2;
plot(Ax2, w./(2*pi*1E6), Xb_ST(2,:))
xline(Ax2, x(2,1), ':');
xline(Ax2, f0(2).*1E-6, '--'); 
Ax2.YAxis.Visible = 'off';
Ax2.Box = 'off';
xlim(Ax2, x(2,:))

% Link the axes
linkaxes([Ax1 Ax2], 'y')

xlabel(t, 'MHz');
ylabel(t, 'Ohms');
title(t, 'Reactance vs. Frequency');

%% Double Tuned Balun
% Properly label values based on Schnall's paper
Ls = Lb;

% Calculate inductance 
L1 = Lb*0.3; % From Matt's paper

% Fixed inductor values (Coilcraft 1111SQ, 1515SQ, 2222SQ, 2929SQ)
L1ops = [27, 30, 33, 36, 39, 43, 47, 68, 82, 90, 100, 110, 130, 160, 180, 220, 270, 300, 330, 360, 390, 430, 500].*10^-9;

% Find closest fix inductor value
L1diff = abs(L1ops - L1);
L1 = L1ops(L1diff == min(L1diff));

%% Calculate capacitance
% Calculate capacitance to tune trap to 1H
C1 = 1/(L1*w0(2)^2);

clear C2

wval = 2*pi*100E3;

% Find first cuton
wdiff = abs(w - (w0(1)-wval));
wcon1 = find(wdiff == min(wdiff));

% Find first cutoff
wdiff = abs(w - (w0(1)+wval));
wcoff1 = find(wdiff == min(wdiff));

% Find second cuton
wdiff = abs(w - (w0(2)-wval));
wcon2 = find(wdiff == min(wdiff));

% Find second cutoff
wdiff = abs(w - (w0(2)+wval));
wcoff2 = find(wdiff == min(wdiff));

% Iterate through capacitor values
for i = 0.2:0.005:1.8
    for j = 0.2:0.005:1.8
        % Select capacitor values
        C1_tmp = C1*i;
        C2_tmp = Cb(1)*j;

        % Calculate reactance for double-tuned balun
        Xb_DT = XLLCC(Ls, C2_tmp, L1, C1_tmp, w);

        % Isolate correct values
        if any(Xb_DT(wcon1:wcoff1) < -0.25E5) && any(Xb_DT(wcon2:wcoff2) < -0.25E5)
            C1 = C1_tmp;
            C2 = C2_tmp;
            break
        end
    end
    if exist('C2', 'var'); break; end
end

clc; 

fprintf('\nLs = %0.1f nH\n', Ls*1E9)
fprintf('L1 = %0.1f nH\n', L1*1E9)
fprintf('C1 = %0.1f pF\n', C1*1E12)
fprintf('C2 = %0.1f pF\n', C2*1E12)

% Plot
% Initialize figure
figure; 
t = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
tAx = axes(t,'XTick',[],'YTick',[],'Box','off'); 
tAx.Layout.TileSpan = [1 2];

% Create first plot
Ax1 = axes(t); Ax1.Layout.Tile = 1;
plot(Ax1, w./(2*pi*1E6), Xb_ST(1,:));
hold on
plot(Ax1, w./(2*pi*1E6), Xb_DT);
hold off
xline(Ax1, x(1,2), ':'); 
xline(Ax1, f0(1).*1E-6, '--'); 
Ax1.Box = 'off'; 
xlim(Ax1, x(1,:));
ylim(Ax1, [-1E5, 1E5]);

% Create second plot
Ax2 = axes(t); Ax2.Layout.Tile = 2;
plot(Ax2, w./(2*pi*1E6), Xb_ST(2,:))
hold on
plot(Ax2, w./(2*pi*1E6), Xb_DT);
hold off
xline(Ax2, x(2,1), ':');
xline(Ax2, f0(2).*1E-6, '--'); 
Ax2.YAxis.Visible = 'off';
Ax2.Box = 'off';
xlim(Ax2, x(2,:));
ylim(Ax2, [-1E5, 1E5]);

% Link the axes
linkaxes([Ax1 Ax2], 'y')

xlabel(t, 'MHz');
ylabel(t, 'Ohms');
title(t, 'Reactance vs. Frequency');
legend('ST', 'DT');

%% Functions
% Calculate inductance of solenoid
function L = Solenoid(r, N, l)
% r = radius, m
% N = number of turns
% l = length, m
u0 = 4*pi*10^-7; % permeability of free space
A = pi*(r^2); % area, m^2

L = u0*A*N^2/l;
end

% Calculate reactance of capacitor
function X = XC(C, w)
% C = capacitance, F
% w = frequency, rad/s
X = -1./(w.*C);
end

% Calculate reactance of inductor
function X = XL(L, w)
% L = inductance, H
% w = frequency, rad/s
X = w.*L;
end

% Calculate reactance of parallel LC circuit
function X = XLC(L, C, w)
X = 1./(1./XL(L,w) + 1./XC(C,w));
end

function X = XLLCC(Ls, C2, L1, C1, w)
% X = 1./(1./XL(Ls,w) + 1./(XC(C2,w) + XLC(L1, C1, w)));
X = 1./(1./XL(Ls,w) + 1./(XC(C2,w) + 1./(1./XL(L1,w) + 1./XC(C1,w))));

end