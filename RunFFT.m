function [THD, YfreqDomain] = RunFFT(y)

Fs = length(y); %sampling rate

[YfreqDomain,frequencyRange] = positiveFFT(y,Fs);
FFT_list=abs(YfreqDomain);

ysquare=y.^2;
y_base_rms=sqrt(sum(ysquare)/120);
baseY=FFT_list(2)/sqrt(2);
THD=sqrt(y_base_rms^2-baseY^2)/baseY*100;