function sd = AnimalMonitorDefaultSD

global AnimalMonitorDefaultSDName;
global AnimalMonitorDefaultSDParams;

if isempty(AnimalMonitorDefaultSDName),
	error(['Could not create default AnimalMonitor SimpleDaq device.  Please make sure global variables AnimalMonitorDefaultSDName and AnimalMonitorDefaultSDParams are defined.']);
end;

sd = NewSimpleDaq(AnimalMonitorDefaultSDName,AnimalMonitorDefaultSDParams);


