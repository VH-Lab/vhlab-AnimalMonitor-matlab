function [ HR ] = AnimalMonitorAnalyzeEKG( HRparams,t,EKG )
%AnimalMonitorAnalyzedEKG will convert artifacts in the HR into 'no-number'
%'No-number'(NaN) will be eliminated from measurements
x=t;
y=EKG;
z=find((y(1:end-1)<HRparams.HRThresholdEdit) & (y(2:end)>HRparams.HRThresholdEdit)); %find where EKG crosses the HR Threshold
discard = 0;
d=[];
i = 1;
l = length(z);

if ~isempty(z),
    timesofpeakcrossings = t(z);
    intervals = diff(timesofpeakcrossings);
    g = find(intervals<1/10)+1;
    notg = setdiff(1:length(timesofpeakcrossings),g);
    timesofpeakcrossings = timesofpeakcrossings(notg);
    HR = 60/median(diff(timesofpeakcrossings));
else,
    timesofpeakcrossings = [];
    HR=0;
end

HR,

if 0,
    while i+discard+1 < l
        if i ~=1
            d = find(z(i+discard:end)<z(i+discard)+1000);
        else
            d = find(z(i+discard:end)<z(i+discard)+1000);
        end
        discard = discard + length(d);
        i=i+1;
        l = length(z);
    end
    a=length(find(y>HRparams.HRArtThresholdEdit));
    if length(find(y>HRparams.HRArtThresholdEdit)); %if EKG exceeds the Artifact Threshold, make HR NaN
        HR=NaN;
        return;
    end
    t(z); %time of EKG crossings of the HR Threshold
    %figure
    %plot(t,EKG)
    %axis([0 5 0 2])
    %hold on
    %plot (t(z),EKG(z),'o')
    r=HRparams.HRRateThresholdEdit; %set r to equal rate threshold
     z2=[]; %define z2 as an empty vector
    for i=1:length(z),
        i;
            d=abs(z(i)-z([1:i-1 i+1:end])); %distance of crossing points of the HR Threshold
        if length(find(d))<r; %if length of the distance between crossing points is less than the Rate Threshold, do nothing

        else
            z2(end+1)=z(i);
        end
    end
    HR=((length(z)-discard)/(t(end)-t(1)))*60;
end

end