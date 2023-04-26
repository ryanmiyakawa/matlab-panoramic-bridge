% Test script for panoramic bridge:
addpath('..');
% Make sure that API server is runnning.
panoramicBridge.init()

p = panoramicBridge;
disp(1)  


aoi = 6;
NAi =  0.55;
anamorphicRatio = 0.5; 
NA = NAi * [1/8, 1/4];
poleRadialSigma = [0.4, 0.9];



 
 
 %% Generate a 2D simulation of dense contacts, anamorphic at 16-nm CD
 
 % Simulation runs in 224 seconds

BASE_CD = 16 * 4;
numPoles = 4;
poleOpenAngle = 30;
poleOffset = 45;

% Load empty 1D sim:
simName = '2D_blank_4_excitations';
p.loadSim(simName);

% Init params:
p.setVariable('lambda', 13.5);
p.setVariable('NA', NAi/2);
p.setVariable('AR', anamorphicRatio);

% Init illumination
p.setVariable('sig1', poleRadialSigma(1));
p.setVariable('sig2', poleRadialSigma(2));
p.setVariable('poleOpenAng', poleOpenAngle);
p.setVariable('numPoles', numPoles);
p.setVariable('poleOffset', poleOffset);

% Define shift-invariant pupil space image stems:
pR = mean(poleRadialSigma) * ones(1, numPoles);
pTh = pi/180 * (poleOffset + (360 / numPoles)*(0:numPoles-1));

pX = pR.*cos(pTh);
pY = pR.*sin(pTh);

plot(cos(linspace(0, 2*pi, 100)), sin(linspace(0, 2*pi, 100)), 'k', pX, pY, 'mx'), axis image, title('Pupil space')

pupilCoordinates = [pX', pY'];

aois = zeros(size(pupilCoordinates, 1), 1);
azis = zeros(size(pupilCoordinates, 1), 1);

for k = 1:size(pupilCoordinates, 1)
    [th, ph] = panoramicBridge.pupilSpaceToAngles(6, (NA), pupilCoordinates(k,:));
    aois(k) = th;
    azis(k) = ph;
end

% Set angle variables:
for k = 1:size(pupilCoordinates, 1)
    p.setVariable(sprintf('aoi%d', k), aois(k));
    p.setVariable(sprintf('azi%d', k), azis(k));
end


p.setVariable('xpitch', BASE_CD * 4);
p.setVariable('ypitch', BASE_CD * 2);
p.setVariable('xcd', BASE_CD * 2);
p.setVariable('ycd', BASE_CD);






% Load intel-specific materials
panoramicBridge.loadMaterials();


% Generate mask stack:
maskType = 'PSM';

% Generate multilayer:
m = maskStackGenerator();
m.generateIMOMultilayer();

% Generate Cap
m.generateIMOCap(maskType);

% Generate absorber blocks:
boxes = [...
    struct('XBounds', {{'0', '$xpitch$'}}, ...
           'YBounds', {{'0', '$ycd$/2'}}), ...
    struct('XBounds', {{'0', '$xcd$/2'}}, ...
           'YBounds', {{'$ycd$/2', '3*$ycd$/2'}}), ...
    struct('XBounds', {{'3*$xcd$/2', '$xpitch$'}}, ...
           'YBounds', {{'$ycd$/2', '3*$ycd$/2'}}), ...
    struct('XBounds', {{'0', '$xpitch$'}}, ...
           'YBounds', {{'3*$ycd$/2', '$ypitch$'}}) ...
]; 

m.generateAbsorberStack(boxes, maskType, 'string');


%save as new:
 p.saveSim('2D-dense-contacts-working');
 
%% Generate a 2D simulation of Hexagonal contacts HV

 % Simulation runs in 718 seconds (12 min)


BASE_CD = 19 * 4;
numPoles = 6;
poleOffset = 0;
poleOpenAngle = 30;

% Load empty 2D sim:
simName = '2D_blank_6_excitations';
p.loadSim(simName);

% Init params:
p.setVariable('lambda', 13.5);
p.setVariable('NA', NAi/2);
p.setVariable('AR', anamorphicRatio);

% Init illumination
p.setVariable('sig1', poleRadialSigma(1));
p.setVariable('sig2', poleRadialSigma(2));
p.setVariable('poleOpenAng', poleOpenAngle);
p.setVariable('numPoles', numPoles);
p.setVariable('poleOffset', poleOffset);

% Define shift-invariant pupil space image stems:
pR = mean(poleRadialSigma) * ones(1, numPoles);
pTh = pi/180 * (poleOffset + (360 / numPoles)*(0:numPoles-1));

pX = pR.*cos(pTh);
pY = pR.*sin(pTh);

plot(cos(linspace(0, 2*pi, 100)), sin(linspace(0, 2*pi, 100)), 'k', pX, pY, 'mx'), axis image, title('Pupil space')

pupilCoordinates = [pX', pY'];

aois = zeros(size(pupilCoordinates, 1), 1);
azis = zeros(size(pupilCoordinates, 1), 1);

for k = 1:size(pupilCoordinates, 1)
    [th, ph] = panoramicBridge.pupilSpaceToAngles(6, (NA), pupilCoordinates(k,:));
    aois(k) = th;
    azis(k) = ph;
end

% Set angle variables:
for k = 1:size(pupilCoordinates, 1)
    p.setVariable(sprintf('aoi%d', k), aois(k));
    p.setVariable(sprintf('azi%d', k), azis(k));
end



p.setVariable('xpitch', BASE_CD * 4);
p.setVariable('ypitch', BASE_CD * 2);
p.setVariable('xcd', BASE_CD * 2);
p.setVariable('ycd', BASE_CD);



xcd = BASE_CD * 2;
ycd = BASE_CD;
Tx = xcd * 2;
Ty = ycd * 3;

p.setVariable('xpitch',Tx);
p.setVariable('ypitch',Ty);
p.setVariable('xcd', xcd);
p.setVariable('ycd', ycd);



% Load intel-specific materials
panoramicBridge.loadMaterials();


% Generate mask stack:
maskType = 'PSM';

% Generate multilayer:
m = maskStackGenerator();
m.generateIMOMultilayer();

% Generate Cap
m.generateIMOCap(maskType);

% Generate absorber blocks:
boxes = [...
    struct('XBounds', {{'$xcd$', '$xpitch$'}}, ...
           'YBounds', {{'3*$ycd$/2', '$ypitch$'}}), ...
    struct('XBounds', {{'0', '$xcd$'}}, ...
           'YBounds', {{'0', '2*$ycd$'}}),...
    struct('XBounds', {{'$xcd$', '$xpitch$'}}, ...
           'YBounds', {{'0', '$ycd$/2'}}), ...
]; 


m.generateAbsorberStack(boxes, maskType, 'string');


%save as new:
 p.saveSim('2D-HV-hexcontacts-working');
 
 
 
  
%% Generate a 2D simulation of Hexagonal contacts VH

BASE_CD = 19 * 4;
numPoles = 6;
poleOffset = 30;
poleOpenAngle = 30;

% Load empty 2D sim:
simName = '2D_blank_6_excitations';
p.loadSim(simName);

% Init params:
p.setVariable('lambda', 13.5);
p.setVariable('NA', NAi/2);
p.setVariable('AR', anamorphicRatio);

% Init illumination
p.setVariable('sig1', poleRadialSigma(1));
p.setVariable('sig2', poleRadialSigma(2));
p.setVariable('poleOpenAng', poleOpenAngle);
p.setVariable('numPoles', numPoles);
p.setVariable('poleOffset', poleOffset);

% Define shift-invariant pupil space image stems:
pR = mean(poleRadialSigma) * ones(1, numPoles);
pTh = pi/180 * (poleOffset + (360 / numPoles)*(0:numPoles-1));

pX = pR.*cos(pTh);
pY = pR.*sin(pTh);

plot(cos(linspace(0, 2*pi, 100)), sin(linspace(0, 2*pi, 100)), 'k', pX, pY, 'mx'), axis image, title('Pupil space')

pupilCoordinates = [pX', pY'];

aois = zeros(size(pupilCoordinates, 1), 1);
azis = zeros(size(pupilCoordinates, 1), 1);

for k = 1:size(pupilCoordinates, 1)
    [th, ph] = panoramicBridge.pupilSpaceToAngles(6, (NA), pupilCoordinates(k,:));
    aois(k) = th;
    azis(k) = ph;
end

% Set angle variables:
for k = 1:size(pupilCoordinates, 1)
    p.setVariable(sprintf('aoi%d', k), aois(k));
    p.setVariable(sprintf('azi%d', k), azis(k));
end


p.setVariable('xpitch', BASE_CD * 4);
p.setVariable('ypitch', BASE_CD * 2);
p.setVariable('xcd', BASE_CD * 2);
p.setVariable('ycd', BASE_CD);

xcd = BASE_CD * 2;
ycd = BASE_CD;
Tx = xcd * 3 ;
Ty = ycd * 2 ;

p.setVariable('xpitch',Tx);
p.setVariable('ypitch',Ty);
p.setVariable('xcd', xcd);
p.setVariable('ycd', ycd);



% Load intel-specific materials
panoramicBridge.loadMaterials();


% Generate mask stack:
maskType = 'PSM';

% Generate multilayer:
m = maskStackGenerator();
m.generateIMOMultilayer();

% Generate Cap
m.generateIMOCap(maskType);

% Generate absorber blocks:
boxes = [...  
    struct('XBounds', {{'$xcd$', '$xpitch$'}}, ...
           'YBounds', {{'$ycd$', '$ypitch$'}}), ...
    struct('XBounds', {{'0', '3*$xcd$/2'}}, ...
           'YBounds', {{'0', '$ycd$'}}),...
    struct('XBounds', {{'5*$xcd$/2', '$xpitch$'}}, ...
           'YBounds', {{'0', '$ycd$'}})...
]; 



m.generateAbsorberStack(boxes, maskType, 'string');


%save as new:
 p.saveSim('2D-VH-hexcontacts-working');
 
 
 %% Generate a 1D simulation of dense L/S at 11-nm CD anamorphic in shadowed direction

BASE_CD = 11 * 4;

% Load empty 1D sim:
simName = '1D_blank';
p.loadSim(simName);

% init params:
p.setVariable('lambda', 13.5);
p.setVariable('pitch', BASE_CD * 4);
p.setVariable('cd', BASE_CD * 2);


% Load intel-specific materials
panoramicBridge.loadMaterials();


% Generate mask stack:
maskType = 'PSM';

% Generate multilayer:
m = maskStackGenerator();
m.generateIMOMultilayer();

% Generate Cap
m.generateIMOCap(maskType);

% Generate absorber blocks:
boxes = [...
    struct('XBounds', {{'$cd$/2', '3*$cd$/2'}}, ...
           'YBounds', [0, 1] ...
)]; 

m.generateAbsorberStack(boxes, maskType, 'string');


%save as new:
 p.saveSim('1D-LS-working');
 
 
 
 