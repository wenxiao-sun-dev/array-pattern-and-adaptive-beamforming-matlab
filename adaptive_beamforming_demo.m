% adaptive_beamforming_demo.m
clear; close all; clc;

% Radar / array parameters
numChannels = 3;
txApertureLength = 1;          % [m]
rxApertureLength = 1/3;        % [m]
wavelength = 0.03;             % [m]

% Target direction
targetDirection = 0;

% Evaluation grid
numGridPoints = 10000;
directionGrid = linspace(-10*wavelength/txApertureLength, 10*wavelength/txApertureLength, numGridPoints);

% Phase center positions
phaseCenters = [-rxApertureLength; 0; rxApertureLength];

% Desired signal steering vector
targetSteeringVector = 1/sqrt(numChannels) ...
    * sinc(targetDirection * txApertureLength / wavelength) ...
    * sinc(targetDirection * rxApertureLength / wavelength) ...
    * exp(1j * 2*pi/wavelength * phaseCenters * targetDirection);

% Steering matrix over direction grid
steeringMatrix = ([1; 1; 1] ...
    * (sinc(directionGrid * txApertureLength / wavelength) ...
    .* sinc(directionGrid * rxApertureLength / wavelength))) ...
    .* exp(1j * 2*pi/wavelength * phaseCenters * directionGrid);

% Conventional beamformer response
conventionalResponse = targetSteeringVector' * steeringMatrix;
conventionalResponse_dB = 20 * log10(abs(conventionalResponse) + eps);
conventionalResponse_dB = conventionalResponse_dB - max(conventionalResponse_dB);

% Interference scenario
noisePower = 1;
jammerDirection = 0.02;
jammerToNoiseRatio_dB = 20;
jammerPower = 10^(jammerToNoiseRatio_dB / 10);

% Noise covariance
noiseCovariance = noisePower * eye(numChannels);

% Jammer steering vector
jammerSteeringVector = 1/sqrt(numChannels) ...
    * sinc(jammerDirection * txApertureLength / wavelength) ...
    * sinc(jammerDirection * rxApertureLength / wavelength) ...
    * exp(1j * 2*pi/wavelength * phaseCenters * jammerDirection);

jammerSignalVector = jammerSteeringVector * sqrt(numChannels);

% Jammer covariance
jammerCovariance = jammerPower * (jammerSignalVector * jammerSignalVector');

% Total covariance
totalCovariance = jammerCovariance + noiseCovariance;

% Adaptive response
adaptiveResponse = targetSteeringVector' * (totalCovariance \ steeringMatrix);
adaptiveResponse_dB = 20 * log10(abs(adaptiveResponse) + eps);
adaptiveResponse_dB = adaptiveResponse_dB - max(adaptiveResponse_dB);

% Plot adaptive response
figure(1);
plot(directionGrid, adaptiveResponse_dB, 'LineWidth', 1.2);
title('Adaptive Beamforming Response');
xlabel('Direction Parameter');
ylabel('Normalized Magnitude (dB)');
ylim([-40 5]);
grid on;

% Plot covariance eigenvalues
covarianceEigenvalues = eig(totalCovariance);

figure(2);
bar(10 * log10(abs(covarianceEigenvalues) + eps));
title('Covariance Matrix Eigenvalues');
xlabel('Eigenvalue Index');
ylabel('Magnitude (dB)');
grid on;