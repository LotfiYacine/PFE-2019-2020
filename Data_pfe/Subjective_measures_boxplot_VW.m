clear all
clc
close all

user_start=1;

[responses_Boxe_ref, responses_Boxe_insistence, responses_Boxe_tap,responses_Boxe_insistence_tap,responses_Boxe_insistence_ref...
    responses_Trike_ref, responses_Trike_insistence, responses_Trike_tap,responses_Trike_insistence_tap,responses_Trike_insistence_ref...
    preference_Boxe_ref_insistence, preference_Trike_ref_insistence,...
    preference_Boxe_insistence_tap, preference_Trike_insistence_tap,...
    detection_Boxe, detection_Trike,...
    orderfordetection_Boxe, orderfordetection_Trike]= all_subjective_measures_Jan2020(user_start);

plotNames = {'Perceived quality', 'Perceived quality variation', 'Comfort', 'Responsiveness to head motion', 'Assessment of available time'};
nb_of_questions = length(plotNames);

colors = [0 0 0; 1 0 0];

foldername = 'figures/';
filenames = {'visualquality','qualityvar','comfort','responsiveness','timeav'};

%% Plot answers to all questions as boxplots
%{
for i = 1:nb_of_questions
    figh=figure('Position', get(0, 'Screensize'));
    set(figh, 'DefaultTextFontSize', 28);
%     tensor_for_box = zeros([length(responses_VW2_ref(:,i)) 6 2]);
    tensor_for_box = zeros([length(responses_VW2_ref(:,i)) 2 2]);
    tensor_for_box(:,1,:)=[responses_VW2_ref(:,i),responses_VW2_effect(:,i)];
    tensor_for_box(:,2,:)=[responses_VWBoxe_ref(:,i),responses_VWBoxe_effect(:,i)];
%     tensor_for_box(:,3,:)=[responses_SD2_ref(:,i),responses_SD2_effect(:,i)];
%     tensor_for_box(:,4,:)=[responses_SDBar_ref(:,i),responses_SDBar_effect(:,i)];
%     tensor_for_box(:,5,:)=[responses_SDUnderwater_ref(:,i),responses_SDUnderwater_effect(:,i)];
%     tensor_for_box(:,6,:)=[responses_SDTouvet_ref(:,i),responses_SDTouvet_effect(:,i)];
    iosr.statistics.boxPlot({'Comb. Rides','Boxing'},tensor_for_box,...
        'notch',false,...
        'medianColor','g',...
        'showMean',true,'meanSize',10,'meanColor','k','lineWidth',2,...
        'symbolMarker',{'o','d'},...
        'boxcolor',{[0.2 0.3 0.9]; [0.9 0.3 0.2]},... %'boxcolor','auto',...
        'style','hierarchy',...
        'xSeparator',true,...
        'groupLabels',{{'ref','effect'}},...
        'groupLabelFontSize',28);
    box on
    %title(plotNames{i})
    if i==1, ylabel('visual quality score'); end
    if i==3, ylabel('comfort score'); end
    if i==4, ylabel('responsiveness score'); end
    ylim([0,5.5]);
    set(gca, 'FontSize',28)
    saveas(figh,[foldername filenames{i}],'fig');
    saveas(figh,[foldername filenames{i}],'epsc');
end
%}

%% Plot answer to the preference question if control is preferable 
videos_vec = {'Boxe', 'Trike'}; 
pref_mat_ref_insistence = [preference_Boxe_ref_insistence,preference_Trike_ref_insistence];

alpha = 0.1; %0.05
figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 26);
place=[0.3 0.8];
hold on
for video_ind=1:length(videos_vec)
    preference = pref_mat_ref_insistence(:,video_ind);
    pd = fitdist(preference,'binomial');
    pd_ci = paramci(pd,alpha);
    confint_low = pd.p-pd_ci(1,2);
    confint_high = pd_ci(2,2)-pd.p;
    bar(place(video_ind), pd.p, 0.1, 'FaceColor',[0.9 0.3 0.2],'EdgeColor',[0 .2 .9],'LineWidth',1.5)
    errorbar(place(video_ind), pd.p,confint_low,confint_high,'k.')
end
%lg=legend('Fraction of users preferring effect over reference');
%lg.FontSize=26;
ylabel('Fraction of users preferring control');
set(gca, 'XTick', place)
set(gca, 'XTickLabel', videos_vec)
set(gca, 'ylim', [0 1])
set(gca, 'xlim', [0 1.1])
set(gca, 'FontSize',26)
hold off
saveas(figh,[foldername 'preference_insistence'],'fig');
saveas(figh,[foldername 'preference_insistence'],'epsc');
saveas(figh,[foldername 'preference_insistence'],'png');

%% Plot answer to the preference question if tap is preferable 
videos_vec = {'Boxe', 'Trike'}; 
pref_mat_insistence_tap = [preference_Boxe_insistence_tap,preference_Trike_insistence_tap];

alpha = 0.1; %0.05
figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 26);
place=[0.3 0.8];
hold on
for video_ind=1:length(videos_vec)
    preference = pref_mat_insistence_tap(:,video_ind);
    pd = fitdist(preference,'binomial');
    pd_ci = paramci(pd,alpha);
    confint_low = pd.p-pd_ci(1,2);
    confint_high = pd_ci(2,2)-pd.p;
    bar(place(video_ind), pd.p, 0.1, 'FaceColor',[0.9 0.3 0.2],'EdgeColor',[0 .2 .9],'LineWidth',1.5)
    errorbar(place(video_ind), pd.p,confint_low,confint_high,'k.')
end
%lg=legend('Fraction of users preferring effect over reference');
%lg.FontSize=26;
ylabel('Fraction of users preferring tap');
set(gca, 'XTick', place)
set(gca, 'XTickLabel', videos_vec)
set(gca, 'ylim', [0 1])
set(gca, 'xlim', [0 1.1])
set(gca, 'FontSize',26)
hold off
saveas(figh,[foldername 'preference_tap'],'fig');
saveas(figh,[foldername 'preference_tap'],'epsc');
saveas(figh,[foldername 'preference_tap'],'png');

%% Plot fraction of users giving a qual<=3 in ref and insistence
%Comment évalueriez-vous la qualité visuelle générale du contenu (la netteté de l'image)?
question_ind=1; % considering mos on quality
resp_mat_ref = [responses_Boxe_ref(:,question_ind),responses_Trike_ref(:,question_ind)]; 
resp_mat_effect = [responses_Boxe_insistence(:,question_ind),responses_Trike_insistence(:,question_ind)]; 

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 28);
mos_cut=2;
hold on
pd_videos=[];
for video_ind=1:length(videos_vec)
    responses_vid_ref = resp_mat_ref(:,video_ind);
    disp(responses_vid_ref)
    responses_vid_effect = resp_mat_effect(:,video_ind);
    pd_mos=[];
    ind_users = (responses_vid_ref<=mos_cut);
    frac_users = sum(ind_users)/length(ind_users);
    pd_mos = [pd_mos,frac_users];
    ind_users = (responses_vid_effect<=mos_cut);
    frac_users = sum(ind_users)/length(ind_users);
    pd_mos = [pd_mos,frac_users];
    pd_videos=[pd_videos;pd_mos];
end

b=bar(pd_videos)
b(1).FaceColor=[0.2 0.3 0.9];
b(2).FaceColor=[0.9 0.3 0.2];
cell_leg=cell(1,2);
cell_leg{1,1}=['  in ref.'];
cell_leg{1,2}=['  in insistence'];
lg=legend(cell_leg);
lg.Title.String = ['visual quality rated\newlinewith score < ' num2str(mos_cut+1)];
lg.FontSize=26;
ylabel('fraction of users')
set(gca, 'XTick', [1:length(videos_vec)])
set(gca, 'XTickLabel', videos_vec)
set(gca, 'ylim', [0 0.7])
set(gca, 'FontSize',28)
hold off
saveas(figh,[foldername 'worstcase_ref_insistence_' filenames{question_ind}],'fig');
saveas(figh,[foldername 'worstcase_ref_insistence_' filenames{question_ind}],'epsc');
saveas(figh,[foldername 'worstcase_ref_insistence_' filenames{question_ind}],'png');


%% Plot fraction of users giving a responsiveness<=3 in ref and insistence
%Comment évalueriez-vous la réactivité du système à votre mouvement de tête? 
question_ind=3; % considering mos on responsiveness
resp_mat_ref = [responses_Boxe_ref(:,question_ind),responses_Trike_ref(:,question_ind)]; 
resp_mat_effect = [responses_Boxe_insistence(:,question_ind),responses_Trike_insistence(:,question_ind)]; 

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 28);
mos_cut=2;
hold on
pd_videos=[];
% cilow_videos=[];
% cihigh_videos=[];
for video_ind=1:length(videos_vec)
    responses_vid_ref = resp_mat_ref(:,video_ind);
    responses_vid_effect = resp_mat_effect(:,video_ind);
    pd_mos=[];
    ind_users = (responses_vid_ref<=mos_cut);
    frac_users = sum(ind_users)/length(ind_users);
    pd_mos = [pd_mos,frac_users];
    ind_users = (responses_vid_effect<=mos_cut);
    frac_users = sum(ind_users)/length(ind_users);
    pd_mos = [pd_mos,frac_users];
    pd_videos=[pd_videos;pd_mos];
end

b=bar(pd_videos)
b(1).FaceColor=[0.2 0.3 0.9];
b(2).FaceColor=[0.9 0.3 0.2];
cell_leg=cell(1,2);
cell_leg{1,1}=['  in ref.'];
cell_leg{1,2}=['  in insistence'];
lg=legend(cell_leg);
lg.Title.String = ['responsiveness rated\newlinewith score < ' num2str(mos_cut+1)];
lg.FontSize=26;
ylabel('fraction of users')
set(gca, 'XTick', [1:length(videos_vec)])
set(gca, 'XTickLabel', videos_vec)
set(gca, 'ylim', [0 0.7])
set(gca, 'FontSize',28)
hold off
saveas(figh,[foldername 'worstcase_resp_ref_insistence_' filenames{question_ind}],'fig');
saveas(figh,[foldername 'worstcase_resp_ref_insistence_' filenames{question_ind}],'epsc');
saveas(figh,[foldername 'worstcase_resp_ref_insistence_' filenames{question_ind}],'png');


%% Plot fraction of users giving a qual<=3 in insistence and tap
%Comment évalueriez-vous la qualité visuelle générale du contenu (la netteté de l'image)?
question_ind=1; % considering mos on quality
resp_mat_ref = [responses_Boxe_insistence(:,question_ind),responses_Trike_insistence(:,question_ind)]; 
resp_mat_effect = [responses_Boxe_tap(:,question_ind),responses_Trike_tap(:,question_ind)]; 

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 28);
mos_cut=2;
hold on
pd_videos=[];
for video_ind=1:length(videos_vec)
    responses_vid_ref = resp_mat_ref(:,video_ind);
    responses_vid_effect = resp_mat_effect(:,video_ind);
    pd_mos=[];
    ind_users = (responses_vid_ref<=mos_cut);
    frac_users = sum(ind_users)/length(ind_users);
    pd_mos = [pd_mos,frac_users];
    ind_users = (responses_vid_effect<=mos_cut);
    frac_users = sum(ind_users)/length(ind_users);
    pd_mos = [pd_mos,frac_users];
    pd_videos=[pd_videos;pd_mos];
end

b=bar(pd_videos)
b(1).FaceColor=[0.2 0.3 0.9];
b(2).FaceColor=[0.9 0.3 0.2];
cell_leg=cell(1,2);
cell_leg{1,1}=['  in insistence.'];
cell_leg{1,2}=['  in tap'];
lg=legend(cell_leg);
lg.Title.String = ['visual quality rated\newlinewith score < ' num2str(mos_cut+1)];
lg.FontSize=26;
ylabel('fraction of users')
set(gca, 'XTick', [1:length(videos_vec)])
set(gca, 'XTickLabel', videos_vec)
set(gca, 'ylim', [0 0.7])
set(gca, 'FontSize',28)
hold off
saveas(figh,[foldername 'worstcase_insistence_tap_' filenames{question_ind}],'fig');
saveas(figh,[foldername 'worstcase_insistence_tap_' filenames{question_ind}],'epsc');
saveas(figh,[foldername 'worstcase_insistence_tap_' filenames{question_ind}],'png');


%% Plot fraction of users giving a responsiveness<=3 in insistence and tap
%Comment évalueriez-vous la réactivité du système à votre mouvement de tête? 
question_ind=3; % considering mos on responsiveness
resp_mat_ref = [responses_Boxe_insistence(:,question_ind),responses_Trike_insistence(:,question_ind)]; 
resp_mat_effect = [responses_Boxe_tap(:,question_ind),responses_Trike_tap(:,question_ind)]; 

figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 28);
mos_cut=2;
hold on
pd_videos=[];
for video_ind=1:length(videos_vec)
    responses_vid_ref = resp_mat_ref(:,video_ind);
    responses_vid_effect = resp_mat_effect(:,video_ind);
    pd_mos=[];
    ind_users = (responses_vid_ref<=mos_cut);
    frac_users = sum(ind_users)/length(ind_users);
    pd_mos = [pd_mos,frac_users];
    ind_users = (responses_vid_effect<=mos_cut);
    frac_users = sum(ind_users)/length(ind_users);
    pd_mos = [pd_mos,frac_users];
    pd_videos=[pd_videos;pd_mos];
end

b=bar(pd_videos)
b(1).FaceColor=[0.2 0.3 0.9];
b(2).FaceColor=[0.9 0.3 0.2];
cell_leg=cell(1,2);
cell_leg{1,1}=['  in insistence.'];
cell_leg{1,2}=['  in tap'];
lg=legend(cell_leg);
lg.Title.String = ['responsiveness rated\newlinewith score < ' num2str(mos_cut+1)];
lg.FontSize=26;
ylabel('fraction of users')
set(gca, 'XTick', [1:length(videos_vec)])
set(gca, 'XTickLabel', videos_vec)
set(gca, 'ylim', [0 0.7])
set(gca, 'FontSize',28)
hold off
saveas(figh,[foldername 'worstcase_resp_insistence_tap_' filenames{question_ind}],'fig');
saveas(figh,[foldername 'worstcase_resp_insistence_tap_' filenames{question_ind}],'epsc');
saveas(figh,[foldername 'worstcase_resp_insistence_tap_' filenames{question_ind}],'png');

%% Plot fraction of users prefering insistence vs assessed visual quality in ref
%{
question_ind=1;
resp_mat_ref = [responses_Boxe_ref(:,question_ind),responses_Trike_ref(:,question_ind)]; 
disp(resp_mat_ref);
disp(pref_mat_ref_insistence);
figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 26);
end_mos=4;
hold on
pd_videos=[];
for video_ind=1:length(videos_vec)
    preference = pref_mat_ref_insistence(:,video_ind);
    responses_vid_ref = resp_mat_ref(:,video_ind);
    pd_mos=[];
%     cimos_low=[];
%     cimos_high=[];
    for mos=1:end_mos
        ind_users = (responses_vid_ref==mos);
        frac_users=0;
        if sum(ind_users)>1, frac_users = sum(preference(ind_users))/sum(ind_users); end
        pd_mos = [pd_mos,frac_users];
    end
    pd_videos=[pd_videos;pd_mos];
end

bar(pd_videos);
cell_leg=cell(1,end_mos);
for mos=1:end_mos, cell_leg{1,mos}=['   ' num2str(mos)]; end
ylabel('Fraction of users prefering insistence')
lg=legend(cell_leg);
lg.Title.String='Visual quality\newlinein ref. rated at:';
lg.FontSize=22;
set(gca, 'XTick', [1:length(videos_vec)])
set(gca, 'XTickLabel', videos_vec)
set(gca, 'ylim', [0 1])
set(gca, 'FontSize',24)
hold off
saveas(figh,[foldername 'prefInsistencevsMOS_' filenames{question_ind}],'fig');
saveas(figh,[foldername 'prefInsistencevsMOS_' filenames{question_ind}],'epsc');
saveas(figh,[foldername 'prefInsistencevsMOS_' filenames{question_ind}],'png');
%}
%% Plot fraction of users prefering tap vs assessed visual quality in insistence
%{
question_ind=1;
resp_mat_ref = [responses_Boxe_insistence_tap(:,question_ind),responses_Trike_insistence_tap(:,question_ind)]; 
disp(resp_mat_ref)
disp(pref_mat_insistence_tap)
figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 26);
end_mos=4;
hold on
pd_videos=[];
for video_ind=1:length(videos_vec)
    preference = pref_mat_insistence_tap(:,video_ind);
    responses_vid_ref = resp_mat_ref(:,video_ind);
    pd_mos=[];
    for mos=1:end_mos
        ind_users = (responses_vid_ref==mos);
        frac_users=0;
        if sum(ind_users)>1, frac_users = sum(preference(ind_users))/sum(ind_users); end
        pd_mos = [pd_mos,frac_users];
    end
    pd_videos=[pd_videos;pd_mos];
    end

bar(pd_videos);
cell_leg=cell(1,end_mos);
for mos=1:end_mos, cell_leg{1,mos}=['   ' num2str(mos)]; end
ylabel('Fraction of users prefering tap')
lg=legend(cell_leg);
lg.Title.String='Visual quality in \newlineinsistence rated at:';
lg.FontSize=22;
set(gca, 'XTick', [1:length(videos_vec)])
set(gca, 'XTickLabel', videos_vec)
set(gca, 'ylim', [0 1])
set(gca, 'FontSize',24)
hold off
saveas(figh,[foldername 'prefTapvsMOS_' filenames{question_ind}],'fig');
saveas(figh,[foldername 'prefTapvsMOS_' filenames{question_ind}],'epsc');
saveas(figh,[foldername 'prefTapvsMOS_' filenames{question_ind}],'png');
%}
%% Plot fraction of users prefering tap vs assessed resposiveness in tap
%Comment évalueriez-vous la réactivité du système à votre mouvement de tête? 
%{
question_ind = 3;
resp_mat_ref = [responses_Boxe_tap(:,question_ind),responses_Trike_tap(:,question_ind)]; 
disp(resp_mat_ref)
disp(pref_mat_insistence_tap)
figh=figure('Position', get(0, 'Screensize'));
set(figh, 'DefaultTextFontSize', 26);
end_mos=5;
hold on
pd_videos=[];
for video_ind=1:length(videos_vec)
    preference = pref_mat_insistence_tap(:,video_ind);
    responses_vid_ref = resp_mat_ref(:,video_ind);
    pd_mos=[];
%     cimos_low=[];
%     cimos_high=[];
    for mos=1:end_mos
        ind_users = (responses_vid_ref==mos);
        frac_users=0;
        if sum(ind_users)>1, frac_users = sum(preference(ind_users))/sum(ind_users); end
        pd_mos = [pd_mos,frac_users];
    end
    pd_videos=[pd_videos;pd_mos];
end

bar(pd_videos);
cell_leg=cell(1,end_mos);
for mos=1:end_mos, cell_leg{1,mos}=['   ' num2str(mos)]; end
ylabel('Fraction of users prefering tap')
lg=legend(cell_leg);
lg.Title.String='Responsiveness\newlinein tap rated at:';
lg.FontSize=22;
set(gca, 'XTick', [1:length(videos_vec)])
set(gca, 'XTickLabel', videos_vec)
set(gca, 'ylim', [0 1])
set(gca, 'FontSize',24)
hold off
saveas(figh,[foldername 'prefTapvsResp_' filenames{question_ind}],'fig');
saveas(figh,[foldername 'prefTapvsResp_' filenames{question_ind}],'epsc');
saveas(figh,[foldername 'prefTapvsResp_' filenames{question_ind}],'png');
%}