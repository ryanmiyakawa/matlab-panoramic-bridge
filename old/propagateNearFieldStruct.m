% Takes a nearfield struct computed by `buildNearFieldLibrary.m`
% and computes aerial image under pupil shifts `dPx` and `dPy`.

function out = propagateNearFieldStruct(nearField, aoi, dPx, dPy)

    % Get domain and NA
    domain = nearField.domain;
    NA = nearField.NA;
    NAx = NA(1);
    NAy = NA(2);
    lambda = nearField.lambda;
    z = domain.z;


    % Filter near field frequencies based on NA

    % First compute frequency grid
    [fy, fx] = freqspace([domain.nx, domain.ny]);
    Fx = fx * domain.nx/2/domain.xSize;
    Fy = fy * domain.ny/2/domain.ySize;

    [FX, FY] = meshgrid(Fx, Fy);

    % convert to pupil coordinates:
    PX = FX * lambda/NAx + dPx + sind(aoi)/NAx;
    PY = FY * lambda/NAy + dPy;


    % get near field spectra:
    fExTE = fftshift(fft2(nearField.EFields.ExTE));
    fEyTE = fftshift(fft2(nearField.EFields.EyTE));
    fEzTE = fftshift(fft2(nearField.EFields.EzTE));
    fExTM = fftshift(fft2(nearField.EFields.ExTM));
    fEyTM = fftshift(fft2(nearField.EFields.EyTM));
    fEzTM = fftshift(fft2(nearField.EFields.EzTM));

    % Filter out frequencies outside of NA:
    mask = (PX.^2 + PY.^2) <= 1;
    fExTE(~mask) = 0;
    fEyTE(~mask) = 0;
    fEzTE(~mask) = 0;
    fExTM(~mask) = 0;
    fEyTM(~mask) = 0;
    fEzTM(~mask) = 0;

    % Propagate to focus:
    H = exp(2i * pi * z/lambda* sqrt(1 - FX.^2 - FY.^2));
    
    fExTEf = fExTE .* H;
    fEyTEf = fEyTE .* H;
    fEzTEf = fEzTE .* H;
    fExTMf = fExTM .* H;
    fEyTMf = fEyTM .* H;
    fEzTMf = fEzTM .* H;

    % Inverse FFT to get fields at focus:
    ExTE = ifft2(ifftshift(fExTEf));
    EyTE = ifft2(ifftshift(fEyTEf));
    EzTE = ifft2(ifftshift(fEzTEf));
    ExTM = ifft2(ifftshift(fExTMf));
    EyTM = ifft2(ifftshift(fEyTMf));
    EzTM = ifft2(ifftshift(fEzTMf));
    
    % combine:
    out = abs(ExTE).^2 + abs(EyTE).^2 + abs(EzTE).^2 + abs(ExTM).^2 + abs(EyTM).^2 + abs(EzTM).^2;




