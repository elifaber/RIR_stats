function [drr, freqs] = calcDRR(x, fs, varargin)
% CALCDRR Calculates Direct-to-Reverberant Ratio (DRR) from a RIR
%
%   [drr, freqs] = calcDRR(x, fs, 'DirectWindow', nSamples, 'cfs', bands)
%
%   INPUTS:
%       x             : Time-domain room impulse response (linear)
%       fs            : Sampling rate (Hz)
%
%   Name-Value Pair Inputs:
%       'DirectWindow' : Duration in ms for direct energy window (default: 1 ms)
%                        This window is centered on the RIR peak
%
%       'cfs'          : Center frequencies for DRR computation.
%                       Set to 0 for broadband; defaults to standard octave bands:
%                       [63, 125, 250, 500, 1000, 2000, 4000, 8000]
%
%   OUTPUTS:
%       drr           : DRR value(s) in dB
%       freqs         : Corresponding frequency bands used (empty if broadband)


    % Input parser
    p = inputParser;
    addRequired(p, 'x', @(x) isnumeric(x) && isvector(x));
    addRequired(p, 'fs', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'DirectWindow', 5, @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'cfs', 0, @(x) isnumeric(x) && isvector(x));

    parse(p, x, fs, varargin{:});

    x            = p.Results.x;
    fs           = p.Results.fs;
    direct_time  = p.Results.DirectWindow;
    cfs          = p.Results.cfs;

    % keep original signal for plotting
    orig_sig = x;
    % if there are specified center freqs 
    if cfs ~= 0
        drr = zeros(length(cfs),1);
        freqs = cfs;
        for i = 1:length(cfs)
            filt = octaveFilter(cfs(i), '1 octave', 'FilterOrder', 6, 'SampleRate', fs);
            temp = filt(x);
            % get nrg
            temp = temp.^2;
            % find max (assumed this is the direct)
            [~,idx] = max(temp);
            % calc DRR
            sample_window = round(fs * direct_time/2e3);
            idx_lo = max(1, idx-sample_window);
            idx_hi = idx+sample_window;
            DRR_num = sum(temp(idx_lo:idx_hi,:));
            DRR_denom = sum(temp(idx_hi:end,:));
            drr(i) = 10*log10(DRR_num/DRR_denom);
        
       
        end
    % broadband case
    else
        freqs = [];
        % get nrg
        x = x.^2;
        % find max (assumed this is the direct)
        [~,idx] = max(x);
        % calc DRR
        sample_window = round(fs * direct_time/2e3);
        idx_lo = max(1, idx-sample_window);
        idx_hi = idx+sample_window;
        DRR_num = sum(x(idx_lo:idx_hi,:));
        DRR_denom = sum(x(idx_hi:end,:));
        drr = 10*log10(DRR_num/DRR_denom);
    end

    % Plotting
    figure;
    t = (0:length(orig_sig)-1)/fs;
    hold on;
    plot(t(idx_lo:idx_hi), orig_sig(idx_lo:idx_hi), 'b', 'LineWidth', 1);
    if idx_lo > 1
        plot(t(1:idx_lo-1), orig_sig(1:idx_lo-1), 'r', 'LineWidth', 1);
    end
    if idx_hi < length(orig_sig)
        plot(t(idx_hi+1:end), orig_sig(idx_hi+1:end), 'r', 'LineWidth', 1);
    end
    xline(t(idx_lo), 'k--', 'LineWidth', 1);
    xline(t(idx_hi), 'k--', 'LineWidth', 1);

    % point at identified peak
    plot(t(idx), orig_sig(idx), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);

    xlabel('Time (s)');
    title('Signal with Direct Sound Window');
    legend('Direct Sound Window', 'Tail', 'Location', 'best');
    grid on;


        

end
