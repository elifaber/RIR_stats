function [rt, freqs] = calcRT(x, fs, varargin)
% CALCRT Calculates reverberation time (RT) from a RIR
%
%   [rt, freqs] = calcRT(x, fs, 'RT_value', val, 'EDT', bool, 'cfs', freqs)
%
%   INPUTS:
%       x         : Time-domain RIR (linear)
%       fs        : Sampling rate (Hz)
%
%   Name-Value Pair Inputs:
%       'RT_value' : RT dB range (e.g. 20 for T20), default = 20
%       'EDT'      : If true, compute EDT (0 to -10 dB), default = false
%       'cfs'      : Center frequencies for RIR computation.
%                    Set to 0 for broadband; defaults to standard octave bands:
%                    [63, 125, 250, 500, 1000, 2000, 4000, 8000]
%
%   OUTPUTS:
%       rt        : RT estimate(s)
%       freqs     : Frequencies used (empty if broadband)

    % Parse inputs
    p = inputParser;
    addRequired(p, 'x', @(x) isnumeric(x) && isvector(x));
    addRequired(p, 'fs', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'RT_value', 20, @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'EDT', false, @(x) islogical(x) || isnumeric(x));
    addParameter(p, 'cfs', [], @(x) isnumeric(x) && isvector(x));

    parse(p, x, fs, varargin{:});

    x = p.Results.x;
    fs = p.Results.fs;
    RT_value = p.Results.RT_value;
    EDT = logical(p.Results.EDT);
    cfs = p.Results.cfs;

    if isempty(cfs)
        cfs = [63, 125, 250, 500, 1000, 2000, 4000, 8000];
    elseif isequal(cfs, 0)
        cfs = 0; % broadband
    end

    % override RT range if EDT is requested
    if EDT
        RT_value = 10;
    end

    % if cfs are specified
    if cfs ~= 0
        freqs = cfs;
        rt = zeros(length(cfs), 1);
        for i = 1:length(cfs)
            filt = octaveFilter(cfs(i), '1 octave', 'FilterOrder', 6, 'SampleRate', fs);
            x_filt = filt(x);
            decay = edc(x_filt);

            if EDT
                idx1 = find(decay < 0, 1, 'first');
                idx2 = find(decay < -10, 1, 'first');
                rt(i) = abs(idx1 - idx2) / fs * 6;
            else
                idx1 = find(decay < -5, 1, 'first');
                idx2 = find(decay < -5 - RT_value, 1, 'first');
                rt(i) = abs(idx1 - idx2) / fs * 60 / RT_value;
            end
        end
    else
        % Broadband
        freqs = [];
        decay = edc(x);
        if EDT
            idx1 = find(decay < 0, 1, 'first');
            idx2 = find(decay < -10, 1, 'first');
            rt = abs(idx1 - idx2) / fs * 6;
        else
            idx1 = find(decay < -5, 1, 'first');
            idx2 = find(decay < -5 - RT_value, 1, 'first');
            rt = abs(idx1 - idx2) / fs * 60 / RT_value;
        end
    end

    % plot decay curve and regression
    figure;
    t = (0:length(decay) - 1) / fs;
    plot(t, decay, 'b', 'LineWidth', 1.25); hold on;
    x_rt = idx1:idx2;
    y_rt = decay(x_rt);
    t_rt = (x_rt - 1) / fs;
    coeffs = polyfit(t_rt, y_rt, 1);
    y_fit = polyval(coeffs, t);

    plot(t_rt, y_rt, 'k', 'LineWidth', 1.5);
    plot(t, y_fit, 'r--', 'LineWidth', 1.25);
    legend('EDC (dB)', 'RT segment', 'Regression line');
    title('Energy Decay Curve');
    xlabel('Time (s)');
    ylabel('Level (dB)');
    grid on;
    hold off;
end

function y = edc(x)
    % Energy Decay Curve (normalized to 0 dB)
    nrg = x.^2;
    edc_nrg = cumsum(nrg, 'reverse');
    y = 10 * log10(edc_nrg / max(edc_nrg));
end
