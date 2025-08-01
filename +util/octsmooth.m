function [y, f] = octsmooth(x, fs, frac)
%OCTSMOOTH Apply fractional-octave smoothing to an input signal's spectrum
%
%   [y, f] = OCTSMOOTH(x, fs, frac)
%
%   INPUTS:
%       x     : Time-domain signal
%       fs    : Sampling rate (Hz)
%       frac  : Fractional octave bandwidth (e.g., 3 for 1/3-octave)
%
%   OUTPUTS:
%       y     : Smoothed power spectrum (in dB)
%       f     : Frequency vector (Hz)

    % fft
    L = length(x);
    X = fft(x);
    X = X(1:floor(L/2)+1) / L;
    nrg = abs(X).^2;                 
    f = fs/L * (0:floor(L/2));

    % logF
    logF = log2(f(:));
    % logF(1) = NaN because F(1)=0
    logF(1) = eps;

    % interpolate to log-frequency uniform spacing
    N = length(f);
    logF_uniform = linspace(logF(1), logF(end), N);
    nrg_uniform = interp1(logF, nrg, logF_uniform, 'linear', 'extrap');
    df = mean(diff(logF_uniform));

    sigma = (1/frac)/pi;  
    num_std = 6;

    M = round(num_std*2 * sigma / df); 
    t = linspace(-num_std*sigma, num_std*sigma, M);
    w = exp(-0.5 * (t / sigma).^2);
    w = w / sum(w);

    
    % zeropad both to length N + M - 1
    L2 = N + M - 1;
    nrg_pad = [nrg_uniform(:); zeros(L2 - N, 1)];
    w_pad = [w(:); zeros(L2 - M, 1)];
    
    % convolve
    Y = ifft(fft(nrg_pad) .* fft(w_pad));
    
    % get relevant portion
    start_idx = floor(M/2) + 1;
    nrg_smooth = Y(start_idx:start_idx+N-1);

    % interpolate back to linear frequency spacing
    y = interp1(logF_uniform, nrg_smooth, logF, 'linear', 'extrap');

    % Convert to dB
    y = 10 * log10(y);


end
