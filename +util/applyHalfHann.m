function [y] = applyHalfHann(x, start_sample, transition_samples, mode)
% APPLYHALFHANN applies half a raised cosine window to a vector (either
% rise or fall)
%
%   [y] = applyHalfHann(x, start_sample, transition_samples, mode)
%
%   INPUTS:
%       x                   : Input signal
%       start_sample        : What sample to start the window
%       transition_sample   : How many samples the window should take
%       mode                : Either 'rise' or 'fall'
%
%   OUTPUTS:
%       y     : Windowed signal

    if ~strcmp(mode, 'rise') && ~strcmp(mode, 'fall')
        warning('Mode must be "rise" or "fall"');
    end
    window = hann(transition_samples * 2);
    wn = zeros(length(x), 1);

    if strcmp(mode, 'rise')
        window = window(1:transition_samples);
        wn(start_sample:start_sample + transition_samples - 1) = window;
        wn(start_sample + transition_samples:end) = 1;
        y = x .* wn;
    elseif strcmp(mode, 'fall')
        window = window(transition_samples + 1:end);
        wn(1:start_sample - 1) = 1;
        wn(start_sample:start_sample + transition_samples - 1) = window;
        y = x .* wn;
    else
        error('Mode must be ''rise'' or ''fall''.');
    end
end
