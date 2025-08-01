%% Prepare RIR

clear;

% load RIR
[x,fs] = audioread('+samples/h252_Auditorium_1txts.wav');


% db plot to find start idx and noise floor idx
subplot(2,1,1);
plot(x);
title('Unwindowed RIR');



% it is important to remove noise, as this may bias results
x_windowed = util.applyHalfHann(x,140,10,'rise');
x = x_windowed(140:end,:);
L = length(x);

subplot(2,1,2);
plot(x);
title('Windowed RIR');

%% Test octSmooth


fftx = fft(x)./L;
fftx = fftx(1:floor(L/2)+1,:);
y_unsmooth = db(abs(fftx));

% Apply 1/3rd octave smoothing
[y,f] = util.octsmooth(x,fs,6);

% Plot the unsmoothed and smoothed output
figure;
semilogx(f, y_unsmooth);
hold on;
semilogx(f,y,'LineWidth',2)
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('1/6th Octave Smoothed Spectrum');
legend('Unsmoothed','Smoothed');
xlim([20,fs/2+1]);
grid on;

%% Test calcRT

[rts, cfs] = util.calcRT(x,fs, 'RT_value', 60, 'EDT', 0);
figure;
semilogx(cfs,rts);
grid on;
title('Reverberation Time')
xlabel('Frequency (Hz)');
ylabel('Reverberation Time (T30)')


%% Test calcClarity

[c50s,~] = util.calcClarity(x,fs,'Ctime',50);
figure;
semilogx(cfs,c50s);
grid on;
title('Clarity')
xlabel('Frequency (Hz)');
ylabel('Clarity (C50)')

%% Test calcDRR

[drr,~] = util.calcDRR(x,fs,"DirectWindow",1);


%% Test calcLEF

clear;

% Get ambisonic RIR and window
[y,fs] = audioread('+samples/0020_1_sh_rirs.wav');
y = util.applyHalfHann(y,19e3,1e3,'fall');
y = y(1:20e3,:);
omni = y(:,1);
lateral = y(:,2);

[LEF,~] = util.calcLEF(lateral,omni,fs);
% max of this is theorhetically 0.33

%% Test calcITD_ILD_IC

clear;

s = sofaread("+samples/mit_kemar_normal_pinna.sofa");
fs = s.SamplingRate;

HRTF_idx = 2;

% pick a random HRTF from dataset
randomHRTF = s.Numerator(HRTF_idx,:,:);
% [samples x 2]
x = permute(randomHRTF,[3,2,1]);
% calc itd, ILD and ic
[itd,ild,ic,f] = util.calcITD_ILD_IC(x,fs);

% plotting
subplot(2,1,1);
semilogx(f,ild,'LineWidth',2);
grid on;
xlabel('Frequency (Hz)');
ylabel('ILD (dB)');
title('Interaural Loudness Difference (Left - Right)');
subplot(2,1,2);
semilogx(f,itd*1e6,'LineWidth',2);
grid on;
xlabel('Frequency (Hz)');
ylabel('ITD (us)');
title('Interaural Time Difference (Right - Left)');


% Estimate azimuth from ITD

% Woodworth model says ITD = r/c * (theta * sin(theta))
% using Kemar head with r = 8.75 cm and speed of sound c = 343
% Average ITD for f < 1.5kHz (most accurate range)

r = 8.75e-2; % head radius in meters
c = 343;     % speed of sound in m/s

freqThreshold = 1500;
itdAvg = mean(itd(f < freqThreshold)); % average ITD below 1.5 kHz

syms theta;
eq1 = abs(itdAvg/(r/c)) == abs(theta) + sin(abs(theta));

est_az = (vpasolve(eq1, theta, [-pi/2 pi/2]) * 180/3.14);
real_az = s.SourcePosition(HRTF_idx,1);
real_az = mod(real_az + 180, 360) - 180;
real_az(real_az > 90)  = 180 - real_az(real_az > 90);
real_az(real_az < -90) = -180 - real_az(real_az < -90);
error_val = abs(real_az - abs(est_az));

disp(['IC: ',num2str(round(ic,3))]);
disp(['AZ estimation Error: ',num2str(double(error_val))]);







