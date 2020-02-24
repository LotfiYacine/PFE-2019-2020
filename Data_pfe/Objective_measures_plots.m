

[duration_hits_Boxe_insistence, duration_hits_Trike_insistence,wall_start_insistence,snap_time_afterwall_insistence,time_disable_wall_Boxe_insistence,time_disable_wall_Trike_insistence,...
    duration_hits_Boxe_tap, duration_hits_Trike_tap,wall_start_tap,snap_time_afterwall_tap,time_disable_wall_Boxe_tap,time_disable_wall_Trike_tap] = all_objective_measures_Jan2020()

foldername = 'figures/';

hit_max=9;%max(d);

%%%----------------insistence -------------------------------
%%%
%%%----------------For VW activate---------------------------
%% Hit duration vs hit order

tensor_duration=zeros([length(duration_hits_Trike_insistence) 2 hit_max]);
for i=1:length(duration_hits_Trike_insistence)
    duration_vec = duration_hits_Trike_insistence{i};
    if isempty(duration_vec), duration_vec=NaN; end
    ind_Trike= (duration_vec(2,:) < time_disable_wall_Trike_insistence(i));
    dur_vec=duration_vec(1,ind_Trike); dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));   
    tensor_duration(i,2,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
    
end
for i=1:length(duration_hits_Boxe_insistence)
    duration_vec = duration_hits_Boxe_insistence{i};
    if isempty(duration_vec), duration_vec=NaN; end 
    %if size(time_disable_wall_Boxe_insistence)>=i, time_disable_wall_Boxe_insistence(i); else, time_disable_wall_Boxe_insistence(i)=60000; end
    ind_Boxe= (duration_vec(2,:) < time_disable_wall_Boxe_insistence(i));
    dur_vec=duration_vec(1,ind_Boxe); dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    tensor_duration(i,1,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end


%% Hit start time vs hit order
tensor_start=zeros([length(duration_hits_Boxe_insistence) 2 hit_max]);
trike_wall_start=wall_start_insistence{2};

for i=1:length(duration_hits_Trike_insistence)
    duration_vec = duration_hits_Trike_insistence{i};
    ind_Trike= (duration_vec(2,:) < time_disable_wall_Trike_insistence(i));
    if isempty(duration_vec), duration_vec=NaN; end
    if ~isnan(duration_vec), dur_vec=duration_vec(2,:)-trike_wall_start(i); else, dur_vec=duration_vec; end
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    dur_vec=dur_vec(1,ind_Trike);
    tensor_start(i,2,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end
boxe_wall_start=wall_start_insistence{1};
for i=1:length(duration_hits_Boxe_insistence)
    duration_vec = duration_hits_Boxe_insistence{i};
    ind_Boxe= (duration_vec(2,:) < time_disable_wall_Boxe_insistence(i));
    if isempty(duration_vec), duration_vec=NaN; end
    if ~isnan(duration_vec), dur_vec=duration_vec(2,:)-boxe_wall_start(i); else, dur_vec=duration_vec; end
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    dur_vec=dur_vec(1,ind_Boxe);
    tensor_start(i,1,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 28);
set(gca, 'FontSize',24)
bar_colors={[1 0 0],[1 0 1],[0 0.5 1],[0 0 1],[0.5 0.5 0.5],[1 0.5 1],[0 1 0],[0 1 1],[1 1 0]};

cell_hitind={'1'};
for i=2:hit_max, cell_hitind{i}=num2str(i); end
bh=iosr.statistics.boxPlot({'Boxe','Trike'},tensor_start,...
        'notch',false,...
        'medianColor','k',...
        'boxcolor',bar_colors,...%'auto',...%'themeColors',{[0.2 0.3 0.9]; [0.9 0.3 0.2]},...
        'style','hierarchy',...
        'xSeparator',true,...
        'groupLabels',{cell_hitind},...
        'groupLabelFontSize',30,...
        'sampleSize',true,'sampleFontSize',16,...
        'showLegend',false); %true
    box on
%ylim([0 10000])
yl=ylabel('time of hit (ms)');
set(gca, 'FontSize',24)
yl.FontSize=36;
saveas(figh,[foldername 'hittimevsorder_ins_VW_activate'],'fig');
saveas(figh,[foldername 'hittimevsorder_ins_VW_activate'],'epsc');
saveas(figh,[foldername 'hittimevsorder_ins_VW_activate'],'png');

%% Plot fraction of user which disables wall during time boxe insistence 
videos_vec = {'Boxe', 'Trike'}; 

boxe_wall_start=wall_start_insistence{1};
alpha = 0.1; %0.05
figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 26);
hold on
x=size(boxe_wall_start,2);
for j=1:size(boxe_wall_start,2)
    temp=[];a=[];b=[];
    wall_start=boxe_wall_start(:,j);
    tdwbi=time_disable_wall_Boxe_insistence(:,j);
    for i=1:length(tdwbi)
        if(tdwbi(i)~=60000)
            tdwbi_temp(i)=tdwbi(i)-wall_start(i);
        else
            tdwbi_temp(i)=tdwbi(i);
        end
    end
    tdwbi_temp(tdwbi_temp>=60000)=[];
    if(isempty(find(hist(tdwbi)==length(tdwbi))))
        if(length(unique(tdwbi_temp))==1)
            a(1)=length(tdwbi_temp);
            b(1)=tdwbi_temp(1);
        else                       
            [a,b]=hist(tdwbi_temp,unique(tdwbi_temp));
        end
    else
        break;
    end
    
    for i=1:length(a)
        temp(i,1)=(sum(a(:,1:i))/length(tdwbi));
    end
    %scatter(b,temp);
    plot(b,temp,'-x');
end
%
yl=ylabel("fraction d'utilisateur");
xl=xlabel("temps mis pour désactivation (ms)");
yl.FontSize=36;
xl.FontSize=36;
set(gca, 'ylim', [0 1])
set(gca, 'xlim', [0 60000],'xtick',0:2000:60000)
saveas(figh,[foldername 'disable_boxe_insistence'],'fig');
saveas(figh,[foldername 'disable_boxe_insistence'],'epsc');
saveas(figh,[foldername 'disable_boxe_insistence'],'png');


%% Plot fraction of user which disables wall during time trike insistence 
videos_vec = {'Boxe', 'Trike'}; 

trike_wall_start=wall_start_insistence{2};
alpha = 0.1; %0.05
figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 26);
hold on
x=size(trike_wall_start,2);
for j=1:size(trike_wall_start,2)
    temp=[];a=[];b=[];
    wall_start=trike_wall_start(:,j);
    tdwbi=time_disable_wall_Trike_insistence(:,j);
    ind_tdwbi_temp=0;
    for i=1:length(tdwbi)
        if(tdwbi(i)~=60000)
            tdwbi_temp(i)=tdwbi(i)-wall_start(i);
        else
            tdwbi_temp(i)=tdwbi(i);
        end
    end
    tdwbi_temp(tdwbi_temp>=60000)=[];
    if(isempty(find(hist(tdwbi)==length(tdwbi))))
        if(length(unique(tdwbi_temp))==1)
            a(1)=length(tdwbi_temp);
            b(1)=tdwbi_temp(1);
        else                       
            [a,b]=hist(tdwbi_temp,unique(tdwbi_temp));
        end
    else
        break;
    end
    
    for i=1:length(a)
        temp(i,1)=(sum(a(:,1:i))/length(tdwbi));
    end
    %scatter(b,temp);
    plot(b,temp,'-x');
end
yl=ylabel("fraction d'utilisateur");
xl=xlabel("temps mis pour désactivation (ms)");
yl.FontSize=36;
xl.FontSize=36;
set(gca, 'ylim', [0 1])
set(gca, 'xlim', [0 60000],'xtick',0:2000:60000)
saveas(figh,[foldername 'disable_trike_insistence'],'fig');
saveas(figh,[foldername 'disable_trike_insistence'],'epsc');
saveas(figh,[foldername 'disable_trike_insistence'],'png');


%% Histogram of number of hits for each wall
mat_nbhits_userxwall = sum(~isnan(tensor_duration),3);
mat_wallxnb = zeros(2,hit_max);
for ind_wall=1:2
    for ind_nb=0:hit_max
        mat_wallxnb(ind_wall,ind_nb+1)=sum(mat_nbhits_userxwall(:,ind_wall)==ind_nb);
    end
end

% restricting to: 0, 0 or 1, more than 2
mat_restr= zeros(2,4);
mat_restr(:,1)=mat_wallxnb(:,1);
mat_restr(:,2)=sum(mat_wallxnb(:,1:4),2);
mat_restr(:,3)=sum(mat_wallxnb(:,5:7),2);
mat_restr(:,4)=sum(mat_wallxnb(:,8:end),2);

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 30);

%bar(mat_wallxnb,'hist')
h=bar(mat_restr)

set(gca,'XTick',1:2)
set(gca,'XtickLabel',{'Boxe','Trike'})
lg=legend('0 hit','less than 3 hits','between 4 and 6','more than 7 hits');
lg.FontSize=28;
yl=ylabel('number of users')
set(gca, 'FontSize',24)
yl.FontSize=36;
saveas(figh,[foldername 'nbofhits_eachwall_ins_VW_activate'],'fig');
saveas(figh,[foldername 'nbofhits_eachwall_ins_VW_activate'],'epsc');
saveas(figh,[foldername 'nbofhits_eachwall_ins_VW_activate'],'png');

%%%----------------For VW desactivate---------------------------
%% Hit duration vs hit order

tensor_duration=zeros([length(duration_hits_Trike_insistence) 2 hit_max]);
for i=1:length(duration_hits_Trike_insistence)
    duration_vec = duration_hits_Trike_insistence{i};
    if isempty(duration_vec), duration_vec=NaN; end
    ind_Trike= (duration_vec(2,:) < time_disable_wall_Trike_insistence(i));
    dur_vec=duration_vec; dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max)); 
    for j=1:length(ind_Trike)
        if(ind_Trike(j)==1)
            dur_vec(j)=NaN;
        end
    end
    tensor_duration(i,2,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
    
end
for i=1:length(duration_hits_Boxe_insistence)
    duration_vec = duration_hits_Boxe_insistence{i};
    if isempty(duration_vec), duration_vec=NaN; end
    ind_Boxe= (duration_vec(2,:) < time_disable_wall_Boxe_insistence(i));
    dur_vec=duration_vec; dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    for j=1:length(ind_Boxe)
        if(ind_Boxe(j)==1)
            dur_vec(j)=NaN;
        end
    end
    tensor_duration(i,1,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end


%% Hit start time vs hit order
tensor_start=zeros([length(duration_hits_Boxe_insistence) 2 hit_max]);
trike_wall_start=wall_start_insistence{2};

for i=1:length(duration_hits_Trike_insistence)
    duration_vec = duration_hits_Trike_insistence{i};
    ind_Trike= (duration_vec(2,:) < time_disable_wall_Trike_insistence(i));
    if isempty(duration_vec), duration_vec=NaN; end
    if ~isnan(duration_vec), dur_vec=duration_vec(2,:)-trike_wall_start(i); else, dur_vec=duration_vec; end
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    for j=1:length(ind_Trike)
        if(ind_Trike(j)==1)
            dur_vec(j)=NaN;
        end
    end
    tensor_start(i,2,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end
boxe_wall_start=wall_start_insistence{1};
for i=1:length(duration_hits_Boxe_insistence)
    duration_vec = duration_hits_Boxe_insistence{i};
    ind_Boxe= (duration_vec(2,:) < time_disable_wall_Boxe_insistence(i));
    if isempty(duration_vec), duration_vec=NaN; end
    if ~isnan(duration_vec), dur_vec=duration_vec(2,:)-boxe_wall_start(i); else, dur_vec=duration_vec; end
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    for j=1:length(ind_Boxe)
        if(ind_Boxe(j)==1)
            dur_vec(j)=NaN;
        end
    end
    tensor_start(i,1,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 28);
set(gca, 'FontSize',24)
bar_colors={[1 0 0],[1 0 1],[0 0.5 1],[0 0 1],[0.5 0.5 0.5],[1 0.5 1],[0 1 0],[0 1 1],[1 1 0]};

cell_hitind={'1'};
for i=2:hit_max, cell_hitind{i}=num2str(i); end
bh=iosr.statistics.boxPlot({'Boxe','Trike'},tensor_start,...
        'notch',false,...
        'medianColor','k',...
        'boxcolor',bar_colors,...%'auto',...%'themeColors',{[0.2 0.3 0.9]; [0.9 0.3 0.2]},...
        'style','hierarchy',...
        'xSeparator',true,...
        'groupLabels',{cell_hitind},...
        'groupLabelFontSize',30,...
        'sampleSize',true,'sampleFontSize',16,...
        'showLegend',false); %true
    box on
%ylim([0 10000])
yl=ylabel('time of hit (ms)');
set(gca, 'FontSize',24)
yl.FontSize=36;
saveas(figh,[foldername 'hittimevsorder_ins_VW_desactivate'],'fig');
saveas(figh,[foldername 'hittimevsorder_ins_VW_desactivate'],'epsc');
saveas(figh,[foldername 'hittimevsorder_ins_VW_desactivate'],'png');


%% Histogram of number of hits for each wall
mat_nbhits_userxwall = sum(~isnan(tensor_duration),3);
mat_wallxnb = zeros(2,hit_max);
for ind_wall=1:2
    for ind_nb=0:hit_max
        mat_wallxnb(ind_wall,ind_nb+1)=sum(mat_nbhits_userxwall(:,ind_wall)==ind_nb);
    end
end

% restricting to: 0, 0 or 1, more than 2
mat_restr= zeros(2,4);
mat_restr(:,1)=mat_wallxnb(:,1);
mat_restr(:,2)=sum(mat_wallxnb(:,1:4),2);
mat_restr(:,3)=sum(mat_wallxnb(:,5:7),2);
mat_restr(:,4)=sum(mat_wallxnb(:,8:end),2);

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 30);

%bar(mat_wallxnb,'hist')
disp(mat_restr)
h=bar(mat_restr)

set(gca,'XTick',1:2)
set(gca,'XtickLabel',{'Boxe','Trike'})
lg=legend('0 hit','less than 3 hits','between 4 and 6','more than 7 hits');
lg.FontSize=28;
yl=ylabel('number of users')
set(gca, 'FontSize',24)
yl.FontSize=36;
saveas(figh,[foldername 'nbofhits_eachwall_ins_VW_desactivate'],'fig');
saveas(figh,[foldername 'nbofhits_eachwall_ins_VW_desactivate'],'epsc');
saveas(figh,[foldername 'nbofhits_eachwall_ins_VW_desactivate'],'png');

%%%----------------TAP-------------------------------------------
%%%
%%%----------------For VW TAP activate---------------------------
%% Hit duration vs hit order

tensor_duration=zeros([length(duration_hits_Trike_tap) 2 hit_max]);
for i=1:length(duration_hits_Trike_tap)
    ind_Trike=0; duration_vec = duration_hits_Trike_tap{i};
    if isempty(duration_vec)
        duration_vec=NaN; 
        dur_vec=duration_vec;
    else
        ind_Trike= (duration_vec(2,:) < time_disable_wall_Trike_tap(i)); 
        dur_vec=duration_vec(1,ind_Trike);   
    end 
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    tensor_duration(i,2,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
    
end
for i=1:length(duration_hits_Boxe_tap)
    ind_Boxe=0; duration_vec = duration_hits_Boxe_tap{i};
    if isempty(duration_vec)
        duration_vec=NaN; 
        dur_vec=duration_vec;
    else
        ind_Boxe= (duration_vec(2,:) < time_disable_wall_Boxe_tap(i));
        dur_vec=duration_vec(1,ind_Boxe);
    end
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    tensor_duration(i,1,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end


%% Hit start time vs hit order
tensor_start=zeros([length(duration_hits_Boxe_tap) 2 hit_max]);
trike_wall_start=wall_start_tap{2};

for i=1:length(duration_hits_Trike_tap)
    ind_Trike=0; duration_vec = duration_hits_Trike_tap{i};   
    if isempty(duration_vec)
        duration_vec=NaN; 
    else
         ind_Trike= (duration_vec(2,:) < time_disable_wall_Trike_tap(i));
    end
    if ~isnan(duration_vec), dur_vec=duration_vec(2,:)-trike_wall_start(i); else, dur_vec=duration_vec; end
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    if ~isnan(dur_vec),dur_vec=dur_vec(1,ind_Trike);end
    tensor_start(i,2,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end
boxe_wall_start=wall_start_tap{1};
for i=1:length(duration_hits_Boxe_tap)
    ind_Boxe=0; duration_vec = duration_hits_Boxe_tap{i};   
    if isempty(duration_vec)
        duration_vec=NaN; 
    else
         ind_Boxe= (duration_vec(2,:) < time_disable_wall_Boxe_tap(i));
    end
    if ~isnan(duration_vec), dur_vec=duration_vec(2,:)-boxe_wall_start(i); else, dur_vec=duration_vec; end
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    if ~isnan(duration_vec),dur_vec=dur_vec(1,ind_Boxe);end
    tensor_start(i,1,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 28);
set(gca, 'FontSize',24)
bar_colors={[1 0 0],[1 0 1],[0 0.5 1],[0 0 1],[0.5 0.5 0.5],[1 0.5 1],[0 1 0],[0 1 1],[1 1 0]};

cell_hitind={'1'};
for i=2:hit_max, cell_hitind{i}=num2str(i); end
bh=iosr.statistics.boxPlot({'Boxe','Trike'},tensor_start,...
        'notch',false,...
        'medianColor','k',...
        'boxcolor',bar_colors,...%'auto',...%'themeColors',{[0.2 0.3 0.9]; [0.9 0.3 0.2]},...
        'style','hierarchy',...
        'xSeparator',true,...
        'groupLabels',{cell_hitind},...
        'groupLabelFontSize',30,...
        'sampleSize',true,'sampleFontSize',16,...
        'showLegend',false); %true
    box on
%ylim([0 10000])
yl=ylabel('time of hit (ms)');
set(gca, 'FontSize',24)
yl.FontSize=36;
saveas(figh,[foldername 'hittimevsorder_tap_VW_activate'],'fig');
saveas(figh,[foldername 'hittimevsorder_tap_VW_activate'],'epsc');
saveas(figh,[foldername 'hittimevsorder_tap_VW_activate'],'png');

%% Plot fraction of user which disables wall during time boxe tap 
videos_vec = {'Boxe', 'Trike'}; 

boxe_wall_start=wall_start_tap{1};
alpha = 0.1; %0.05
figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 26);
hold on
x=size(boxe_wall_start,2);
for j=1:size(boxe_wall_start,2)
    temp=[];a=[];b=[];
    wall_start=boxe_wall_start(:,j);
    tdwbi=time_disable_wall_Boxe_tap(:,j);
    for i=1:length(tdwbi)
        if(tdwbi(i)~=60000)
            tdwbi_temp(i)=tdwbi(i)-wall_start(i);
        else
            tdwbi_temp(i)=tdwbi(i);
        end
    end
    tdwbi_temp(tdwbi_temp>=60000)=[];
    if(isempty(find(hist(tdwbi)==length(tdwbi))))
        if(length(unique(tdwbi_temp))==1)
            a(1)=length(tdwbi_temp);
            b(1)=tdwbi_temp(1);
        else                       
            [a,b]=hist(tdwbi_temp,unique(tdwbi_temp));
        end
    else
        break;
    end
    
    for i=1:length(a)
        temp(i,1)=(sum(a(:,1:i))/length(tdwbi));
    end
    %scatter(b,temp);
    plot(b,temp,'-x');
end
yl=ylabel("fraction d'utilisateur");
xl=xlabel("temps mis pour désactivation (ms)");
yl.FontSize=36;
xl.FontSize=36;
set(gca, 'ylim', [0 1])
set(gca, 'xlim', [0 60000],'xtick',0:2000:60000)
saveas(figh,[foldername 'disable_boxe_tap'],'fig');
saveas(figh,[foldername 'disable_boxe_tap'],'epsc');
saveas(figh,[foldername 'disable_boxe_tap'],'png');


%% Plot fraction of user which disables wall during time trike tap 
videos_vec = {'Boxe', 'Trike'}; 

trike_wall_start=wall_start_tap{2};
alpha = 0.1; %0.05
figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 26);
hold on
x=size(trike_wall_start,2);
for j=1:size(trike_wall_start,2)
    temp=[];a=[];b=[];
    wall_start=trike_wall_start(:,j);
    tdwbi=time_disable_wall_Trike_tap(:,j);
    ind_tdwbi_temp=0;
    for i=1:length(tdwbi)
        if(tdwbi(i)~=60000)
            tdwbi_temp(i)=tdwbi(i)-wall_start(i);
        else
            tdwbi_temp(i)=tdwbi(i);
        end
    end
    tdwbi_temp(tdwbi_temp>=60000)=[];
    if(isempty(find(hist(tdwbi)==length(tdwbi))))      
       if(length(unique(tdwbi_temp))==1)
            a(1)=length(tdwbi_temp);
            b(1)=tdwbi_temp(1);
        else                       
            [a,b]=hist(tdwbi_temp,unique(tdwbi_temp));
        end
    else
        break;
    end
    
    for i=1:length(a)
        temp(i,1)=(sum(a(:,1:i))/length(tdwbi));
    end
    %scatter(b,temp);
    plot(b,temp,'-x');
end
%plot(b,temp,'-x');
yl=ylabel("fraction d'utilisateur");
xl=xlabel("temps mis pour désactivation (ms)");
yl.FontSize=36;
xl.FontSize=36;
set(gca, 'ylim', [0 1])
set(gca, 'xlim', [0 60000],'xtick',0:2000:60000)
saveas(figh,[foldername 'disable_trike_tap'],'fig');
saveas(figh,[foldername 'disable_trike_tap'],'epsc');
saveas(figh,[foldername 'disable_trike_tap'],'png');


%% Histogram of number of hits for each wall
mat_nbhits_userxwall = sum(~isnan(tensor_duration),3);
mat_wallxnb = zeros(2,hit_max);
for ind_wall=1:2
    for ind_nb=0:hit_max
        mat_wallxnb(ind_wall,ind_nb+1)=sum(mat_nbhits_userxwall(:,ind_wall)==ind_nb);
    end
end

% restricting to: 0, 0 or 1, more than 2
mat_restr= zeros(2,4);
mat_restr(:,1)=mat_wallxnb(:,1);
mat_restr(:,2)=sum(mat_wallxnb(:,1:4),2);
mat_restr(:,3)=sum(mat_wallxnb(:,5:7),2);
mat_restr(:,4)=sum(mat_wallxnb(:,8:end),2);

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 30);

%bar(mat_wallxnb,'hist')
disp(mat_restr)
h=bar(mat_restr)

set(gca,'XTick',1:2)
set(gca,'XtickLabel',{'Boxe','Trike'})
lg=legend('0 hit','less than 3 hits','between 4 and 6','more than 7 hits');
lg.FontSize=28;
yl=ylabel('number of users')
set(gca, 'FontSize',24)
yl.FontSize=36;
saveas(figh,[foldername 'nbofhits_eachwall_tap_VW_activate'],'fig');
saveas(figh,[foldername 'nbofhits_eachwall_tap_VW_activate'],'epsc');
saveas(figh,[foldername 'nbofhits_eachwall_tap_VW_activate'],'png');


%%%----------------For VW tap desactivate---------------------------
%% Hit duration vs hit order

tensor_duration=zeros([length(duration_hits_Trike_tap) 2 hit_max]);
for i=1:length(duration_hits_Trike_tap)
    ind_Trike=0; duration_vec = duration_hits_Trike_tap{i};
    if isempty(duration_vec)
        duration_vec=NaN; 
    else
        ind_Trike= (duration_vec(2,:) < time_disable_wall_Trike_tap(i)); 
    end
    dur_vec=duration_vec; dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max)); 
    for j=1:length(ind_Trike)
        if(ind_Trike(j)==1)
            dur_vec(j)=NaN;
        end
    end
    tensor_duration(i,2,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
    
end
for i=1:length(duration_hits_Boxe_tap)
    ind_Boxe=0; duration_vec = duration_hits_Boxe_tap{i};
    if isempty(duration_vec)
        duration_vec=NaN; 
    else
        ind_Boxe= (duration_vec(2,:) < time_disable_wall_Boxe_tap(i)); 
    end
    dur_vec=duration_vec; dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    for j=1:length(ind_Boxe)
        if(ind_Boxe(j)==1)
            dur_vec(j)=NaN;
        end
    end
    tensor_duration(i,1,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end


%% Hit start time vs hit order
tensor_start=zeros([length(duration_hits_Boxe_tap) 2 hit_max]);
trike_wall_start=wall_start_tap{2};

for i=1:length(duration_hits_Trike_tap)
    ind_Trike=0; duration_vec = duration_hits_Trike_tap{i};    
    if isempty(duration_vec), duration_vec=NaN; else ind_Trike= (duration_vec(2,:) < time_disable_wall_Trike_tap(i));end
    if ~isnan(duration_vec), dur_vec=duration_vec(2,:)-trike_wall_start(i); else, dur_vec=duration_vec; end
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    for j=1:length(ind_Trike)
        if(ind_Trike(j)==1)
            dur_vec(j)=NaN;
        end
    end
    tensor_start(i,2,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end
boxe_wall_start=wall_start_tap{1};
for i=1:length(duration_hits_Boxe_tap)
    ind_Boxe=0; duration_vec = duration_hits_Boxe_tap{i};    
    if isempty(duration_vec), duration_vec=NaN; else ind_Boxe= (duration_vec(2,:) < time_disable_wall_Boxe_tap(i));end
    if ~isnan(duration_vec), dur_vec=duration_vec(2,:)-boxe_wall_start(i); else, dur_vec=duration_vec; end
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    for j=1:length(ind_Boxe)
        if(ind_Boxe(j)==1)
            dur_vec(j)=NaN;
        end
    end
    tensor_start(i,1,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 28);
set(gca, 'FontSize',24)
bar_colors={[1 0 0],[1 0 1],[0 0.5 1],[0 0 1],[0.5 0.5 0.5],[1 0.5 1],[0 1 0],[0 1 1],[1 1 0]};

cell_hitind={'1'};
for i=2:hit_max, cell_hitind{i}=num2str(i); end
bh=iosr.statistics.boxPlot({'Boxe','Trike'},tensor_start,...
        'notch',false,...
        'medianColor','k',...
        'boxcolor',bar_colors,...%'auto',...%'themeColors',{[0.2 0.3 0.9]; [0.9 0.3 0.2]},...
        'style','hierarchy',...
        'xSeparator',true,...
        'groupLabels',{cell_hitind},...
        'groupLabelFontSize',30,...
        'sampleSize',true,'sampleFontSize',16,...
        'showLegend',false); %true
    box on
%ylim([0 10000])
yl=ylabel('time of hit (ms)');
set(gca, 'FontSize',24)
yl.FontSize=36;
saveas(figh,[foldername 'hittimevsorder_tap_VW_desactivate'],'fig');
saveas(figh,[foldername 'hittimevsorder_tap_VW_desactivate'],'epsc');
saveas(figh,[foldername 'hittimevsorder_tap_VW_desactivate'],'png');


%% Histogram of number of hits for each wall
mat_nbhits_userxwall = sum(~isnan(tensor_duration),3);
mat_wallxnb = zeros(2,hit_max);
for ind_wall=1:2
    for ind_nb=0:hit_max
        mat_wallxnb(ind_wall,ind_nb+1)=sum(mat_nbhits_userxwall(:,ind_wall)==ind_nb);
    end
end

% restricting to: 0, 0 or 1, more than 2
mat_restr= zeros(2,4);
mat_restr(:,1)=mat_wallxnb(:,1);
mat_restr(:,2)=sum(mat_wallxnb(:,1:4),2);
mat_restr(:,3)=sum(mat_wallxnb(:,5:7),2);
mat_restr(:,4)=sum(mat_wallxnb(:,8:end),2);

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 30);

%bar(mat_wallxnb,'hist')
disp(mat_restr)
h=bar(mat_restr)

set(gca,'XTick',1:2)
set(gca,'XtickLabel',{'Boxe','Trike'})
lg=legend('0 hit','less than 3 hits','between 4 and 6','more than 7 hits');
lg.FontSize=28;
yl=ylabel('number of users')
set(gca, 'FontSize',24)
yl.FontSize=36;
saveas(figh,[foldername 'nbofhits_eachwall_tap_VW_desactivate'],'fig');
saveas(figh,[foldername 'nbofhits_eachwall_tap_VW_desactivate'],'epsc');
saveas(figh,[foldername 'nbofhits_eachwall_tap_VW_desactivate'],'png');

%% Hit depth vs hit order
%{
duration_hits=[duration_hits_Boxe,duration_hits_Trike];
[s,d] = cellfun(@size,duration_hits);
hit_max=7;%max(d);

tensor_depth=zeros([length(duration_hits_Boxe) 2 hit_max]);
trike_wall_start=wall_start{2};
for i=1:length(duration_hits_Trike)
    duration_vec = duration_hits_Trike{i};
    ind_Trike= (duration_vec(2,:) < time_disable_wall_Trike(i));
    if isempty(duration_vec), duration_vec=NaN; end
    if ~isnan(duration_vec), dur_vec=duration_vec(3,:); else, dur_vec=duration_vec; end
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    dur_vec=dur_vec(1,ind_Trike);
    tensor_depth(i,2,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end
boxe_wall_start=wall_start{1};
for i=1:length(duration_hits_Boxe)
    duration_vec = duration_hits_Boxe{i};
    ind_Boxe= (duration_vec(2,:) < time_disable_wall_Boxe(i));
    if isempty(duration_vec), duration_vec=NaN; end
    if ~isnan(duration_vec), dur_vec=duration_vec(3,:); else, dur_vec=duration_vec; end
    dur_vec=dur_vec(1,1:min(size(dur_vec,2),hit_max));
    dur_vec=dur_vec(1,ind_Boxe);
    tensor_depth(i,1,:)=[dur_vec,NaN*ones(1,hit_max-size(dur_vec,2))];
end

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 22);
%for 7 bars
% bar_colors={[0,0.447,0.741],[0.85,0.325,0.098],[0.929,0.694,0.125],...
%     [0.494,0.184,0.556],[0.466,0.674,0.188],[0.301,0.745,0.933],[0.635,0.078,0.184]};
% bar_colors={'r','m','b','g','c','y','w'}; %[0 0.5 1]
bar_colors={[1 0 0],[1 0 1],[0 0.5 1],[0 1 0],[0 1 1],[1 1 0],[1 1 1]};
    
cell_hitind={'1'};
for i=2:hit_max, cell_hitind{i}=num2str(i); end
%}
%{
bh=iosr.statistics.boxPlot({'Boxe','Trike'},tensor_depth,...
        'notch',false,...
        'medianColor','k',...
        'boxcolor',bar_colors,...%'auto',...%'themeColors',{[0.2 0.3 0.9]; [0.9 0.3 0.2]},...
        'style','hierarchy',...
        'xSeparator',true,...
        'groupLabels',{cell_hitind},...
        'groupLabelFontSize',20,...
        'sampleSize',true,'sampleFontSize',12,...
        'showLegend',false); %true
    box on
    
%ylim([0 10000])
ylabel('depth of hit (ms)')
set(gca, 'FontSize',24)
saveas(figh,[foldername 'hitdepthvsorder'],'fig');
saveas(figh,[foldername 'hitdepthvsorder'],'epsc');
%}

%% Scatter plot between each pair {comfort, responsiveness} vs {nb of hits, time in wall, depth in wall}

%{
[responses_Boxe_ref, responses_Boxe_insistence, responses_Boxe_tap,responses_Boxe_insistence_tap,responses_Boxe_insistence_ref...
    responses_Trike_ref, responses_Trike_insistence, responses_Trike_tap,responses_Trike_insistence_tap,responses_Trike_insistence_ref...
    preference_Boxe_ref_insistence, preference_Trike_ref_insistence,...
    preference_Boxe_insistence_tap, preference_Trike_insistence_tap,...
    detection_Boxe, detection_Trike,...
    orderfordetection_Boxe, orderfordetection_Trike]= all_subjective_measures_Jan2020;

question_ind=1;
quality_Boxe = responses_Boxe_insistence(:,question_ind);
quality_Trike = responses_Trike_insistence(:,question_ind);
question_ind=2;
comfort_Boxe = responses_Boxe_insistence(:,question_ind);
comfort_Trike = responses_Trike_insistence(:,question_ind);
question_ind=3;
responsiveness_Boxe = responses_Boxe_insistence(:,question_ind);
responsiveness_Trike = responses_Trike_insistence(:,question_ind);

avg_hits_users_Boxe=sum(sum(~isnan(tensor_duration(:,1:2,:)),3),2)/2;
avg_hitduration_users_Boxe=nanmedian(nanmedian((tensor_duration(:,1:2,:)),3),2);
avg_hitdepth_users_Boxe=nanmedian(nanmedian((tensor_depth(:,1:2,:)),3),2);
avg_hits_users_Trike=sum(sum(~isnan(tensor_duration(:,2,:)),3),2);
avg_hitduration_users_Trike=nanmedian(nanmedian((tensor_duration(:,2,:)),3),2);
avg_hitdepth_users_Trike=nanmedian(nanmedian((tensor_depth(:,2,:)),3),2);
avg_hitduration_users_Trike(isnan(avg_hitduration_users_Trike))=0;
avg_hitdepth_users_Trike(isnan(avg_hitdepth_users_Trike))=0;
disp([avg_hits_users_Boxe;avg_hits_users_Trike])
disp([avg_hitduration_users_Boxe;avg_hitduration_users_Trike])
disp([avg_hitdepth_users_Boxe;avg_hitdepth_users_Trike])
disp([comfort_Boxe;comfort_Trike])
disp([responsiveness_Boxe;responsiveness_Trike])
disp([quality_Boxe;quality_Trike])
disp('Correlation matrix between num of hits, hit duration, hit depth, and comfort, responsiveness, quality:')
corr_matrix = corrcoef([[avg_hits_users_Boxe;avg_hits_users_Trike],[avg_hitduration_users_Boxe;avg_hitduration_users_Trike],[avg_hitdepth_users_Boxe;avg_hitdepth_users_Trike],...
    [comfort_Boxe;comfort_Trike],[responsiveness_Boxe;responsiveness_Trike],[quality_Boxe;quality_Trike]])

%% hits vs comfort and duration vs responsiveness

hits_vec=[];
duration_vec=[];
depth_vec=[];
mos_vec=[];
for level_MOS=1:5
    ind_VW2 = (comfort_Boxe==level_MOS);
    ind_VWBoxe = (comfort_Trike==level_MOS);
    if sum([ind_VW2;ind_VWBoxe])
        mos_vec=[mos_vec;repmat(level_MOS,sum([ind_VW2;ind_VWBoxe]),1)];
        hits_vec=[hits_vec;avg_hits_users_Boxe(ind_VW2);avg_hits_users_Trike(ind_VWBoxe)];
        duration_vec=[duration_vec;avg_hitduration_users_Boxe(ind_VW2);avg_hitduration_users_Trike(ind_VWBoxe)];
        depth_vec=[depth_vec;avg_hitdepth_users_Boxe(ind_VW2);avg_hitdepth_users_Trike(ind_VWBoxe)];
    end
end
figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 28);
boxplot(hits_vec,mos_vec,'Widths',0.5);
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', 'g');
set(findobj(gca,'type','line'),'linew',2)
xlabel('comfort score')
ylabel('Num. of hits per wall')
ylim([0 6])
set(gca, 'FontSize',28)
saveas(figh,[foldername 'comfortvshits'],'fig');
saveas(figh,[foldername 'comfortvshits'],'epsc');


%% hits vs comfort vs quality

quality_vec=[];
mos_vec=[];
for level_MOS=1:5
    ind_VW2 = (comfort_Boxe==level_MOS);
    ind_VWBoxe = (comfort_Trike==level_MOS);
    if sum([ind_VW2;ind_VWBoxe])
        mos_vec=[mos_vec;repmat(level_MOS,sum([ind_VW2;ind_VWBoxe]),1)];
        quality_vec=[quality_vec;quality_Boxe(ind_VW2);quality_Trike(ind_VWBoxe)];
    end
end
figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 28);
boxplot(quality_vec,mos_vec,'Widths',0.5);
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', 'g');
set(findobj(gca,'type','line'),'linew',2)
xlabel('comfort score')
ylabel('quality score')
ylim([0 6])
set(gca, 'FontSize',28)
saveas(figh,[foldername 'comfortvsqual'],'fig');
saveas(figh,[foldername 'comfortvsqual'],'epsc');
%}
