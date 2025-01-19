
function [Heart_rate,breath_rate,mean_HR,mean_BR,message]=ECG(age1,gender1)

%training data set preperation (Commented till line143)

%arrhythmia rythm
%   dinfo = dir('A:/Dataset/arrhythmia/*.mat');
%  file='A:/Dataset/arrhythmia/';
%   l=length(dinfo);
%   ecg_arr1=zeros(l,3600);
%   ecg_arr=zeros(l,3600);
%   for K = 1 : l
%     filename = dinfo(K).name;  
%     b= load(strcat(file,filename)); 
%     ecg_arr1(K,:)=b.val(1,:);
%     ecg_arr1(K,:)=(ecg_arr1(K,:)-1024)/200;
%   end
% 
%   f_s=360; %sampling frequency
%  N=length(ecg_arr1);
%  t=[0:N-1]/f_s;
%  [b,a]=butter(2,2/f_s,'high');
%  for i=1:size(ecg_arr1,1)
%      ecg_arr(i,:)=filter(b,a,ecg_arr1(i,:));
%  end
%  
%  [qrspeaks1,locs1] = findpeaks(ecg_arr(1,:),t,'MinPeakHeight',0.2,'MinPeakDistance',0.5);
%    min2=length(locs1);
%    for i=1:size(ecg_arr,1)  
%        [qrspeaks1,locs1] = findpeaks(ecg_arr(i,:),t,'MinPeakHeight',0.2,'MinPeakDistance',0.5);
%        if length(locs1)<min2
%            min2=length(locs1);
%        end
%    end
%  %square matrix with minimum number of peak locations
% peak2=zeros(size(ecg_arr,1),min2);
% for i=1:size(ecg_arr,1)
%     [qrspeaks1,locs1] = findpeaks(ecg_arr(i,:),t,'MinPeakHeight',0.2,'MinPeakDistance',0.5);
%     peak2(i,:)=locs1(1:min2);
% end
% %peak-peak interval
% peak_interval2=zeros(size(peak2,1),size(peak2,2));
% for i=1:size(peak2,1)
%     for j=2:size(peak2,2)
%         peak_interval2(i,j-1)=peak2(i,j)-peak2(i,j-1);
%     end
% end
%  
%  
%  %normal sinus rhythm
%  dinfo = dir('A:/Dataset/Normal sinus/*.mat');
%  file='A:/Dataset/Normal sinus/';
%  l=length(dinfo);
%  ecg_normal=zeros(l,1280);
% % 
% % 
%  for K = 1 : l
%    filename = dinfo(K).name;  
%    a= load(strcat(file,filename)); 
%    ecg_normal(K,:)=a.val(1,:);
%    ecg_normal(K,:)=ecg_normal(K,:)/200;
% 
%  end
%  f_s=128; %sampling frequency
%   N=length(ecg_normal);
%   t=[0:N-1]/f_s;
%   [b,a]=butter(3,2/f_s,'high');
%  for i=1:size(ecg_normal,1)
%      ecg_normal(i,:)=filter(b,a,ecg_normal(i,:));
%  end
%  
% %   square matrix formation using minimum number of peaks
%  peak1=zeros(size(ecg_normal,1),min2);
%  for i=1:size(ecg_normal,1)
%      [qrspeaks1,locs1] = findpeaks(ecg_normal(i,:),t,'MinPeakHeight',0.35,'MinPeakDistance',0.08);
%      peak1(i,:)=locs1(1:min2);
%  end
%  
%   %finding peak to peak intervals
% peak_interval1=zeros(size(peak1,1),size(peak1,2));
% for i=1:size(peak1,1)
%     for j=2:size(peak1,2)
%         peak_interval1(i,j-1)=peak1(i,j)-peak1(i,j-1);
%     end
% end
% 
%  %feature extraction
%  peak_interval=[peak_interval1;peak_interval2];
%  avg_RR=mean(peak_interval,2);
%  max_RR=max(peak_interval,[],2);
%  min_RR=min(peak_interval,[],2);
%  normalized_max_diff=(max_RR-min_RR)./avg_RR;
%  standard_dev=std(peak_interval,[],2);
%  coefficient_of_var=standard_dev./avg_RR;
%  normalized_abs_deviation=mean((peak_interval-avg_RR)./avg_RR,2);
%  age=[32,20,28,38,42,35,26,32,20,45,32,26,34,41,45,34,38,50,69,75,84,60,66,73,24,63,87,64,47,54,24,72,39];
%  age=age';
%  gender=[1,0,0,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0,1,0,0,1,0,0,0,1,0,1,0,1,0,0,0];
%  gender=gender';
% 
% 
% %root mean square of successive differences between RR intervals
% RMSSD=zeros(size(peak_interval,1),1);
% for i=1:size(peak_interval,1)
%     for j=1:size(peak_interval,2)-1
%         RMSSD(i,:)=RMSSD(i,:)+(sqrt((peak_interval(i,j+1)-peak_interval(i,j)).^2/(size(peak_interval,2)-1)));
%     end
% end
%     
%      %output label matrix
%      % 0 -----> normal sinus
%      % 1 -----> arrhythmia
%  y1=zeros(size(peak_interval1,1),1);
%  y2=ones(size(peak_interval2,1),1);
%  y=[y1;y2];
% 
% %input matrix    
% X=[age gender avg_RR normalized_max_diff RMSSD coefficient_of_var normalized_abs_deviation];
% 
% %extracting radar heart rate and breathing rate
% 
% dinfo = dir('C:/Users/krishna/Desktop/heart_rate/*.txt');
% file='C:/Users/krishna/Desktop/heart_rate/';
% l=length(dinfo);
% Heart_rate=zeros(l,1);
% for K = 1 : length(dinfo)
%   filename = dinfo(K).name;  
%   a = load(strcat(file,filename)); 
%   a = nonzeros(a');
%   Heart_rate(K,:)=mean(a);
%   %fprintf('%4.4f\n',data );   
% end
% 
% dinfo = dir('C:/Users/krishna/Desktop/breath_rate/*.txt');
% file='C:/Users/krishna/Desktop/breath_rate/';
% l=length(dinfo);
% breath_rate=zeros(l,1);
% for K = 1 : length(dinfo)
%   filename = dinfo(K).name;  
%   b = load(strcat(file,filename)); 
%   b = nonzeros(b');
%   breath_rate(K,:)= mean(b);
%    %fprintf('%4.4f\n',data );   
% end

%loading Trained model of neural network
if isfile('net.mat')
    load net.mat
    trained_model=net;
else
    trained_model=neural_network_ecg(X,y);
end

%testing network
[X_test,target]=test(age1,gender1);     
prediction=trained_model(X_test');
%compute performance for testing
e = gsubtract(target,prediction);
performance = perform(trained_model,target,prediction);
tind = vec2ind(target);
yind = vec2ind(prediction);
percentErrors = sum(tind ~= yind)/numel(tind);
figure, ploterrhist(e),title('error histogram for testing data')
figure, plotconfusion(target',prediction),title('Confusion plot for testing data')
figure, plotroc(target',prediction),title('region of convergence for testing data')
[~,c,~]=confusion(target',prediction);
testing_accuracy=c(1,1)/length(target);
mean_HR=mean(Heart_rate);
mean_BR=mean(breath_rate);
count1=0;count2=0;
for i=1:length(prediction)
    if int64(round(prediction(i)))==0
        count1=count1+1;
    else
        count2=count2+1;
    end
end
if count1>count2 || c(1,1)>c(2,2)
    message=strcat('Normal sinus rythm is detected with an accuracy of ',num2str(testing_accuracy*100));

else
    message=strcat('Arrhythmia is detected with an accuracy of ',num2str(testing_accuracy*100));

 end


end