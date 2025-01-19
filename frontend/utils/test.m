function [X_test,target]=test(age,gender)
%test dataset preperation using radar signal database
dinfo = dir('C:/Users/krishna/Desktop/heart_wave/*.txt');
file='C:/Users/krishna/Desktop/heart_wave/';
l=length(dinfo);
HR=zeros(l,128);
for K = 1 : length(dinfo)
  filename = dinfo(K).name;  
  HR(K,:) = load(strcat(file,filename)); 
  %fprintf('%4.4f\n',data );   
end
f_s=5; %sampling frequency
Expected_sampling_fre=360;
interpolation_factor=round(Expected_sampling_fre/f_s);
for i=1:size(HR,1)
    HR_upsampled(i,:)=upsample(HR(i,:),interpolation_factor);
end
N=length(HR_upsampled(1,:));
t=[0:N-1]/Expected_sampling_fre;
%finding minimum number of peaks
[qrspeaks,locs] = findpeaks(HR_upsampled(1,:),t,'MinPeakHeight',0.05,'MinPeakDistance',0.3);
  min1=length(locs);
  for i=1:size(HR,1)  
      [qrspeaks1,locs1] = findpeaks(HR_upsampled(i,:),t,'MinPeakHeight',0.05,'MinPeakDistance',0.3);
      if length(locs1)<min1
          min1=length(locs1);
      end
  end
%taking only minimum number of peak locations
HR_locs=zeros(size(HR_upsampled,1),min1);
for i=1:size(HR,1)
    [~,locs] = findpeaks(HR_upsampled(i,:),t,'MinPeakHeight',0.05,'MinPeakDistance',0.3);
    HR_locs(i,:)=locs(1:min1);
end
%finding peak to peak intervals
peak_interval=zeros(size(HR_locs,1),size(HR_locs,2));
for i=1:size(HR_locs,1)
    for j=2:size(HR_locs,2)
        peak_interval(i,j-1)=HR_locs(i,j)-HR_locs(i,j-1);
    end
end

avg_RR=mean(peak_interval,2);
 max_RR=max(peak_interval,[],2);
 min_RR=min(peak_interval,[],2);
 normalized_max_diff=(max_RR-min_RR)./avg_RR;
 standard_dev=std(peak_interval,[],2);
 coefficient_of_var=standard_dev./avg_RR;
 normalized_abs_deviation=mean((peak_interval-avg_RR)./avg_RR,2);
 
RMSSD=zeros(size(peak_interval,1),1);
for i=1:size(peak_interval,1)
    for j=1:size(peak_interval,2)-1
        RMSSD(i,:)=RMSSD(i,:)+(sqrt((peak_interval(i,j+1)-peak_interval(i,j)).^2/(size(peak_interval,2)-1)));
    end
end

age=age.*ones(size(HR_locs,1),1);
if strcmp(gender,'male')
    gender=ones(size(HR_locs,1),1);
end
if strcmp(gender,'female')
    gender=zeros(size(HR_locs,1),1);
end
X_test=[age gender avg_RR normalized_max_diff RMSSD coefficient_of_var normalized_abs_deviation];
target=zeros(l,1);
% T = array2table(X_test,'VariableNames',{'age', 'gender', 'avg_RR', 'normalized_max_diff', 'RMSSD', 'coefficient_of_var', 'normalized_abs_deviation'})
end