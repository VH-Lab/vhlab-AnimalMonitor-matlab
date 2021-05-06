function AnimalMonitorSave(ds, EKG, EKGtime)
% AnimalMonitorSave - Save the EKG data
%
% AnimalMonitorSave(DS, EKG, EKGTIME)
%
% Saves the AnimalMonitor EKG data to a new test directory.
%
% 

newdir = newtestdir(ds);

try,
	mkdir([getpathname(ds) filesep newdir]);
end;

currenttime = now();


save([getpathname(ds) filesep newdir filesep 'EKGdata.mat'],'EKG','EKGtime','currenttime');

