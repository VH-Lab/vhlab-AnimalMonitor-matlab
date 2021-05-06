function varargout=AnimalMonitor(arg1, arg2, arg3)

AnimalMonitorCalibrate;

if nargin==0,
	command = 'init';
	% use defaults
	mydir = uigetdir([],'Select an experiment directory for monitoring...');
	if ~eqlen(mydir,0)
		try,
			ud.ds = dirstruct(mydir);
		catch,
			errstr = ['Could not open directory ' mydir '.'];
			errordlg(errstr);
			error(errstr);
		end;
	else,
		return;
	end;
	ud.sd = AnimalMonitorDefaultSD;
elseif nargin==1&ischar(arg1),
	command = 'init';
	% is a directory
	try,
		ud.ds = dirstruct(arg1);
	catch,
		errstr = ['Could not open directory ' mydir '.'];
		errordlg(errstr);
		error(errstr);
	end;
	ud.sd = AnimalMonitorDefaultSD;
elseif nargin==1, % this is a callback object
		command = arg1;
elseif nargin==2|nargin==3,
	if isstruct(arg2), % then it is a directory and simpledaq
		ud.ds = dirstruct(arg1);
		ud.sd = arg2;
		command = 'init';
	else, % then arg1 is command string, arg3 is the figure
		command = arg1;
		fig = arg3;
		ud = get(fig,'userdata');
	end;
end;

if ~isa(command,'char'),
	command = get(command,'Tag');
	fig = gcbf;
	ud = get(fig,'userdata');
end;

command,

switch command,

	case 'init',
                button.Units = 'pixels';
                button.BackgroundColor = [0.5 0.5 0.5];
                button.HorizontalAlignment = 'center';
                button.Callback = 'genercallback';
                txt.Units = 'pixels'; txt.BackgroundColor = 0*[0.8 0.8 0.8];
		txt.ForegroundColor = [0.5 0.5 0.5];
                txt.fontsize = 12; txt.fontweight = 'normal';
                txt.HorizontalAlignment = 'center';txt.Style='text';
                edit = txt; edit.BackgroundColor = [ 1 1 1]*0.5; edit.Style = 'Edit';
		edit.fontsize=10; edit.ForegroundColor = [0 0 0];
                popup = txt; popup.style = 'popupmenu';
                cb = txt; cb.Style = 'Checkbox'; cb.Callback = 'genercallback';
                cb.fontsize = 12;

		fig= figure('position',[30 30 1200 700],'color',[0 0 0],'tag','AnimalMonitor');

		% screen resolution is 1366 x 768

		axh = 170;
		axsp = 50;
		axtop = 670;

		axes('units','pixels','position',[50 axtop-axh 850 axh ],'tag','HRAxes', ...
			'color',[0 0 0],'ycolor',0.5*[1 1 1],'xcolor',0.5*[1 1 1]);
		xlabel('Time (hours)','color',0.5*[1 1 1]);
		ylabel('Rate (Hz / 60)','color',0.5*[1 1 1]);

		axes('units','pixels','position',[50 axtop-2*axh-axsp 500 axh ],'tag','EKGAxes', ...
			'color',[0 0 0],'ycolor',0.5*[1 1 1],'xcolor',[0 0 0]);
		ylabel('EKG','color',0.5*[1 1 1]);

		axes('units','pixels','position',[50 axtop-3*axh-2*axsp 500 axh ],'tag','EEGAxes', ...
			'color',[0 0 0],'ycolor',0.5*[1 1 1],'xcolor',0.5+[0 0 0]);
		ylabel('EEG','color',0.5*[1 1 1]);
		xlabel('Time (sec)','color',0.5*[1 1 1]);

		axes('units','pixels','position',[650 axtop-3*axh-2*axsp 300 axh ],'tag','EEGPowAxes', ...
			'color',[0 0 0],'ycolor',0.5*[1 1 1],'xcolor',0.5+[0 0 0]);
		ylabel('EEG power','color',0.5*[1 1 1]);
		xlabel('Frequency (Hz)','color',0.5*[1 1 1]);

		uicontrol(button,'position',[1000 670-50 100 50],'string','GO',...
			'fontsize',16,'tag','GO','ForegroundColor',[0 0.5 0],'fontweight','bold');
		uicontrol(button,'position',[1000 670-100 100 50],'string','1 STEP',...
			'fontsize',16,'tag','STEP','ForegroundColor',[0.5 0.5 0],'fontweight','bold');

		uicontrol(txt,'position',[600 440 260 20],'string','Heart rate parameters');
		uicontrol(txt,'position',[600 400 130 20],'string','Threshold',...
				'horizontalalignment','left');
		uicontrol(edit,'position',[730 400 130 20]','string','','tag','HRThresholdEdit');
		uicontrol(txt,'position',[600 375 130 20],'string','Artifact threshold',...
				'horizontalalignment','left');
		uicontrol(edit,'position',[730 375 130 20]','string','','tag','HRArtThresholdEdit');
		uicontrol(txt,'position',[600 350 130 20],'string','Rate threshold',...
				'horizontalalignment','left');
		uicontrol(edit,'position',[730 350 130 20]','string','','tag','HRRateThresholdEdit');
		uicontrol(txt,'position',[600 325 130 20],'string','Alarm [low high]',...
				'horizontalalignment','left');
		uicontrol(edit,'position',[730 325 130 20]','string','','tag','HRAlarmEdit');
		uicontrol(txt,'position',[600 300 130 20],'string','Last reading',...
				'horizontalalignment','left');
		uicontrol(txt,'position',[730 300 130 20],'string','',...
				'horizontalalignment','left','tag','LastReadingTxt');


		ud.EKG = [];
		ud.EKGt = [];
		ud.EKGtime = [];
		ud.EKGvalue = [];
		ud.EEG = []; 
		ud.EEGtime = []; 
		ud.EEGfreq = [];
		ud.EEGpow = [];
		ud.HRparams = [];
		ud.EKGeventtimes = [];
		ud.loopend = 0;
		ud.currentloop = 0;
	
		AnimalMonitor('SetHeartParametersDefaults',[],fig);
		set(fig,'userdata',ud);


	case 'GO',
		ud.loopend = Inf;
		ud.currentloop = 0;
        ud.sd = OpenSimpleDaq(ud.sd);
		set(fig,'userdata',ud);
		AnimalMonitor('Next',[],fig);
	case 'STEP',
		ud.loopend = 1;
        ud.sd = OpenSimpleDaq(ud.sd);
		ud.currentloop = 0;
		set(fig,'userdata',ud);
		AnimalMonitor('Next',[],fig);
	case 'Next',
		while ud.currentloop < ud.loopend,
			% get analysis parameters
			ud.HRparams = AnimalMonitor('GetHeartParameters',[],fig);
			% read data
			[data,ud.sd] = AcquireSimpleDaq(ud.sd);
			ud.EKGt = data.data{1}(1,:);
			ud.EEGtime = data.data{1}(1,:);
			ud.EKG = data.data{1}(2,:);
			ud.EEG = data.data{1}(3,:);
			% analyze data
			ud.EKGtime(end+1) = datenum(data.starttime);
			%AnimalMonitorAnalyzeEKG(ud.HRparams,ud.EKGt,ud.EKG )
			ud.EKGvalue(end+1) = AnimalMonitorAnalyzeEKG(ud.HRparams,ud.EKGt,ud.EKG);
			%ud.EKGvalue(end+1) = 300+rand;
			[ak, ud.EEGfreq]=fouriercoeffs(ud.EEG, ud.EEGtime(2)-ud.EEGtime(1));
			[ud.EEGtime(2)-ud.EEGtime(1)]
			ud.EEGpow=real(ak).*real(ak);
			% plot data
			set(fig,'userdata',ud);
			AnimalMonitor('Plot',[],fig);
			% save data
			AnimalMonitorSave(ud.ds,ud.EKG,ud.EKGt);
			ud.currentloop = ud.currentloop + 1;
			set(fig,'userdata',ud);
		end;
        ud.sd=CloseSimpleDaq(ud.sd);
        set(fig,'userdata',ud);
	case 'PlotHR',
		currax = gca;
		hr_axes = findobj(fig,'tag','HRAxes');
		axes(hr_axes);
		hold off;
		if length(ud.EKGtime)>1,
%			plot((      ud.EKGtime-ud.EKGtime(1))*24,ud.EKGvalue(ud.currentloop+1),'ro-');
		plot((      ud.EKGtime-ud.EKGtime(1))*24,ud.EKGvalue,'ro-');
		end;
		A = axis;
		hold on;
		plot([A(1:2)],[1 1]*ud.HRparams.HRAlarmEdit(1),'b--');
		plot([A(1:2)],[1 1]*ud.HRparams.HRAlarmEdit(2),'g--');
		set(gca,'tag','HRAxes','color',[0 0 0]);
                set(gca,'ycolor',0.5*[1 1 1],'xcolor',0.5*[1 1 1]);
                xlabel('Time (hours)','color',0.5*[1 1 1]);
                ylabel('Rate (Hz / 60)','color',0.5*[1 1 1]);
		yrange = [100 450];
		axis([A(1) A(2) yrange(1:2)]);
		axes(currax);
		set(findobj(fig,'tag','LastReadingTxt'),'string',num2str(ud.EKGvalue(end)));
	case 'PlotEKG',
		currax = gca;
		ekg_axes = findobj(fig,'tag','EKGAxes');
		axes(ekg_axes);
		hold off;
		plot(ud.EKGt,ud.EKG,'r');
		hold on;
		plot(ud.EKGeventtimes,ud.HRparams.HRThresholdEdit*ones(size(ud.EKGeventtimes)),'ro');
		plot([min(ud.EKGt) max(ud.EKGt)],[1 1]*ud.HRparams.HRThresholdEdit,'b--');
		plot([min(ud.EKGt) max(ud.EKGt)],[1 1]*ud.HRparams.HRArtThresholdEdit,'g--');
		set(gca,'tag','EKGAxes','color',[0 0 0],'ycolor',0.5*[1 1 1],'xcolor',[0 0 0]);
                ylabel('EKG','color',0.5*[1 1 1]);
		axes(currax);
	case 'PlotEEG',
		currax = gca;
		eeg_axes = findobj(fig,'tag','EEGAxes');
		axes(eeg_axes);
		hold off;
		plot(ud.EEGtime,ud.EEG,'color',[0.5 0.5 0.5]);
		set(gca,'tag','EEGAxes','color',[0 0 0],'ycolor',0.5*[1 1 1],'xcolor',0.5+[0 0 0]);
                ylabel('EEG','color',0.5*[1 1 1]);
                xlabel('Time (sec)','color',0.5*[1 1 1]);
		axes(currax);
	case 'PlotEEGPower',
		currax = gca;
		eegpower_axes = findobj(fig,'tag','EEGPowAxes');
		hold off;
		plot(ud.EEGfreq(2:end),ud.EEGpow(2:end),'g-');
		a=axis;
		axis ([0 40 a(3) a(4)])
		set(gca,'tag','EEGPowAxes','color',[0 0 0],'ycolor',0.5*[1 1 1],'xcolor',0.5+[0 0 0]);
                ylabel('EEG power','color',0.5*[1 1 1]);
                xlabel('Frequency (Hz)','color',0.5*[1 1 1]);
		axes(currax);
	case 'Plot',
		AnimalMonitor('PlotHR',[],fig);
		AnimalMonitor('PlotEKG',[],fig);
		AnimalMonitor('PlotEEG',[],fig);
		AnimalMonitor('PlotEEGPower',[],fig);
		drawnow;
	case 'SetHeartParametersDefaults',
		tags = {'HRThresholdEdit','HRArtThresholdEdit','HRRateThresholdEdit',...
			'HRAlarmEdit'};
		defaults = {'0.5','2.0','600','[250 400]'};
		for i=1:length(tags),
			set(findobj(fig,'tag',tags{i}),'string',defaults{i});
		end;
	case 'GetHeartParameters',
		tags = {'HRThresholdEdit','HRArtThresholdEdit','HRRateThresholdEdit',...
			'HRAlarmEdit'};
		for i=1:length(tags),
			str = get(findobj(fig,'tag',tags{i}),'string');
			try,
				eval(['params.' tags{i} '=' str ';']);
			catch,
				errordlg(['Syntax error in ' tags{i} ': ' str '.']);
				error(['Could not get Heart Rate parameters']);
			end;
		end;
		varargout{1} = params;
end;
