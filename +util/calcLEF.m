function [lef, freqs] = calcLEF(x_lateral, x_total, fs, varargin)
% CALCLEF Calculates the Lateral Energy Fraction (LEF) from a RIR
%
%   [lef, freqs] = calcLEF(x_lateral, x_total, fs, 'cfs', bands)
%
%   INPUTS:
%       x_lateral      : Time-domain lateral energy impulse response (linear)
%                        (figure 8 mic with null pointing at source)
%
%       x_total        : Time-domain total (omnidirectional) impulse response (linear)
%
%       fs             : Sampling rate (Hz)
%
%   Name-Value Pair Inputs:
%       'cfs'          : Center frequencies for LEF computation.
%                        Use 0 for broadband (default: 0)
%                        Example: [250 500 1000 2000]
%
%   OUTPUTS:
%       lef            : Lateral energy fraction value(s)
%                        Ratio of lateral energy to total energy (0–1)
%
%       freqs          : Corresponding frequency bands used (empty if broadband)
%
%   Reference:
%       See page 325 of https://doi.org/10.1007/978-1-4939-0755-7

    p = inputParser;
    addRequired(p, 'x_lateral', @(x) isnumeric(x) && isvector(x));
    addRequired(p, 'x_total', @(x) isnumeric(x) && isvector(x));
    addRequired(p, 'fs', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'cfs', 0, @(x) isnumeric(x) && isvector(x));

    parse(p, x_lateral, x_total, fs, varargin{:});
    x_lateral = p.Results.x_lateral;
    x_total   = p.Results.x_total;
    fs        = p.Results.fs;
    cfs       = p.Results.cfs;

    % 5 and 80 ms windows
    win_ms = 80; 
    win_idx = round(win_ms / 1000 * fs);
    five_ms = round(5 / 1000 * fs);

    % broadband case
    if isequal(cfs, 0)
        freqs = [];
        lat_win = x_lateral(five_ms:win_idx).^2;
        tot_win = x_total(1:win_idx).^2;
        lef = sum(lat_win) / sum(tot_win);
    % not broadband case
    else
        lef = zeros(size(cfs));
        freqs = cfs;
        for i = 1:length(cfs)
            f = cfs(i);
            filt = octaveFilter(f, '1 octave', 'FilterOrder', 6, 'SampleRate', fs);
            lat_filt = filt(x_lateral(five_ms:win_idx)).^2;
            tot_filt = filt(x_total(1:win_idx)).^2;
            lef(i) = sum(lat_filt(idx_peak:idx_hi)) / sum(tot_filt(idx_peak:idx_hi));
        end
    end
end
