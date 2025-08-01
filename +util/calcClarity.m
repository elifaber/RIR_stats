function [clarity, freqs] = calcClarity(x, fs, varargin)
% CALCLARITY Calculates clarity (C50,C80, or any other interval) from a RIR
%
%   [clarity, freqs] = calcClarity(x, fs, 'Ctime', value, 'cfs', freqs)
%
%   INPUTS:
%       x         : Time-domain room impulse response (linear)
%       fs        : Sampling rate (Hz)
%
%   Name-Value Pair Inputs:
%       'Ctime'   : Clarity time (default: 50 ms)
%                   Common values: 50 for speech clarity (C50),
%                                  80 for music clarity (C80)
%       'cfs'     : Center frequencies
%                   Set to 0 for broadband; defaults to standard octave bands:
%                   [63, 125, 250, 500, 1000, 2000, 4000, 8000]
%
%   OUTPUTS:
%       clarity   : Clarity values (in dB)
%       freqs     : Corresponding center frequencies used (empty for broadband)

    % Input parser
    p = inputParser;
    addRequired(p, 'x', @(x) isnumeric(x) && isvector(x));
    addRequired(p, 'fs', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'Ctime', 50, @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'cfs', [], @(x) isnumeric(x) && isvector(x));

    parse(p, x, fs, varargin{:});

    x      = p.Results.x;
    fs     = p.Results.fs;
    Ctime  = p.Results.Ctime;
    cfs    = p.Results.cfs;

    % default center frequencies
    if isempty(cfs)
        cfs = [63, 125, 250, 500, 1000, 2000, 4000, 8000];
    elseif isequal(cfs, 0)
        cfs = 0;
    end

    % if there are specified center freqs
    if cfs ~= 0
        freqs = cfs;
        clarity = zeros(length(cfs), 1);
        for i = 1:length(cfs)
            % filter into octave bands
            filt = octaveFilter(cfs(i), '1 octave', 'FilterOrder', 6, 'SampleRate', fs);
            x_filt = filt(x);
            % get nrg
            nrg = x_filt.^2;
            % calculate clarity
            c_num = sum(nrg(1:round((Ctime/1e3)*fs)));
            c_denom = sum(nrg(round((Ctime/1e3)*fs)+1:end));
            clarity(i) = 10*log10(c_num/c_denom);
    
       
        end
    % broadband case
    else
        
        freqs = [];
        % get nrg
        nrg = x.^2;
        % calculate calrity
        c_num = sum(nrg(1:round(Ctime*fs)));
        c_denom = sum(nrg(round(Ctime*fs)+1:end));
        clarity = 10*log10(c_num/c_denom);
    end

    % plotting
    figure;
    split_idx = round(Ctime/1e3 * fs);
    t = (0:length(x)-1)/fs;
    plot(t(1:split_idx), x(1:split_idx), 'b', 'LineWidth', 1);
    hold on;
    plot(t(split_idx+1:end), x(split_idx+1:end), 'r', 'LineWidth', 1);
    xline(t(split_idx), 'k--', 'LineWidth', 1);
    xlabel('Time (s)');
    title('Signal with Clarity Time');
    legend('Before Clarity Time', 'After Clarity Time', 'Clarity Time Boundary');
    grid on;
    hold off;



end
