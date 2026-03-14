% ula_pattern_taylor_demo.m
clear; close all; clc;

% Array parameters
wavelength = 0.03;                  % [m]
numElements = 500;                  % Number of array elements
elementSpacing = wavelength / 2;    % [m]
steeringDirection = 0;              % Direction cosine
numGridPoints = 10000;              % Number of evaluation points

% Direction grid
directionGrid = linspace(-1, 1, numGridPoints);

% Example element pattern
elementPattern = cos(pi * directionGrid / 3).^2;

% Steering vector for beamformer design direction
elementIndex = (0:numElements-1).';
steeringVector0 = exp(-1j * 2*pi/wavelength * elementIndex * elementSpacing * steeringDirection);

% Taylor weighting
windowWeights = taylorwin(numElements, 5, -35);
beamWeights = (windowWeights .* steeringVector0) / sqrt(numElements);

% Output initialization
arrayResponse = zeros(size(directionGrid));

% Evaluate array response
for idx = 1:numGridPoints
    currentDirection = directionGrid(idx);
    steeringVector = exp(-1j * 2*pi/wavelength * elementIndex * elementSpacing * currentDirection);
    arraySignal = elementPattern(idx) * steeringVector;
    arrayResponse(idx) = beamWeights' * arraySignal;
end

% Normalize and convert to dB
arrayResponse_dB = 20 * log10(abs(arrayResponse) + eps);
arrayResponse_dB = arrayResponse_dB - max(arrayResponse_dB);

% Plot
figure;
plot(directionGrid, arrayResponse_dB, 'LineWidth', 1.2);
title('ULA Pattern with Taylor Weighting');
xlabel('Direction Cosine u');
ylabel('Normalized Magnitude (dB)');
ylim([-40 5]);
grid on;