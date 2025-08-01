function [itd, ild, ic, freqs] = calcITD_ILD_IC(x, fs)
% CALCITD_ILD_IC Computes interaural time difference (ITD),
% interaural level difference (ILD), and interaural coherence (IC)
%
%   [itd, ild, ic, freqs] = calcITD_ILD_IC(x, fs)
%
%   INPUTS:
%       x         : Stereo time-domain impulse response [N x 2]
%                   Column 1 = left ear, Column 2 = right ear (linear scale)
%       fs        : Sampling rate (Hz)
%
%   OUTPUTS:
%       itd       : Frequency-dependent Interaural Time Difference (s)
%                   Positive = earlier arrival at left ear
%
%       ild       : Frequency-dependent Interaural Level Difference (dB)
%                   Positive = louder at left ear
%
%       ic        : Interaural Coherence [0–1]
%                   (1 - IACC) where 1 is perfect correlation
% 
%       freqs     : Center frequencies corresponding to ITD, ILD, and IC (Hz)
%
%   NOTES:
%       - ITD is most reliable for frequencies below ~1.5 kHz
%       - ILD is most reliable for frequencies above ~4 kHz


    % extract left and right ears
    L = x(:,1);
    R = x(:,2);

    % smooth spectrums
    [L_db, freqs] = util.octsmooth(L, fs, 3);  
    [R_db, ~]     = util.octsmooth(R, fs, 3);
    % calc ild
    ild = L_db - R_db;

    % fft
    L_fft = fft(L)./length(L);
    R_fft = fft(R)./length(R);

    % get phase angle and calc ITD
    phi_L = unwrap(angle(L_fft(1:floor(length(L)/2)+1)));
    phi_R = unwrap(angle(R_fft(1:floor(length(R)/2)+1)));
    dphi = phi_R - phi_L;
    df = freqs(2) - freqs(1);
    dphi_df = gradient(dphi, df);
    itd = -1 / (2*pi) * dphi_df;

    % calc IC
    one_ms = round(1e-3 * fs);
    norm_factor = sqrt(sum(L.^2) * sum(R.^2));
    [xcorr_vals, ~] = xcorr(L, R, one_ms);
    ic = 1 - max(abs(xcorr_vals/norm_factor));
    



end
