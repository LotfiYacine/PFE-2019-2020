function [responses_Boxe_ref, responses_Boxe_insistence, responses_Boxe_tap,responses_Boxe_insistence_tap,responses_Boxe_insistence_ref...
    responses_Trike_ref, responses_Trike_insistence, responses_Trike_tap,responses_Trike_insistence_tap,responses_Trike_insistence_ref...
    preference_Boxe_ref_insistence, preference_Trike_ref_insistence,...
    preference_Boxe_insistence_tap, preference_Trike_insistence_tap,...
    detection_Boxe, detection_Trike,...
    orderfordetection_Boxe, orderfordetection_Trike]= all_subjective_measures_Jan2020(user_start)
% One line per user
% Question answers in order on columns: 'Perceived quality' | 'Perceived
% quality variation' | 'Comfort' | 'Responsiveness to head motion' |
% 'Assessment of available time'

if nargin==0
    user_start=1;
end

videos_vec = {'Boxe', 'Trike'};
cols_start_video = [3 + (0:2)*11];
cols_mapping_video = [3+ (0:2)*4];

[num_res, txt_res, data_res] = xlsread('./Resulting_questionnaires/Questionnaire_on_experiments.xlsx');
[num_mapping, txt_mapping, data_mapping] = xlsread('./Resulting_questionnaires/Table_users_videos.xlsx');

nb_total_users = size(num_res,1);

%% Responses to common questions -------------

responses_Boxe_ref = [];
responses_Boxe_insistence = [];
responses_Boxe_tap = [];
responses_Boxe_insistence_ref = [];
responses_Boxe_insistence_tap = [];
responses_Trike_ref = [];
responses_Trike_insistence = [];
responses_Trike_tap = [];
responses_Trike_insistence_ref = [];
responses_Trike_insistence_tap = [];

for ind_user = user_start+1:nb_total_users+1 % to skip first row with column description
    
    user_id = data_res{ind_user,1};
    ind_row_mapping = find(cell2mat(data_mapping(2:end,1))==user_id)+1;
    
    for ind_video = 1:length(videos_vec)
        col_mapping_video = cols_mapping_video(ind_video);
        col_start_video = cols_start_video(ind_video);
        col_start_effect1 = col_start_video;
        col_end_effect1 = col_start_effect1 + 3;
        col_start_effect2 = col_start_video + 6;
        col_end_effect2 = col_start_effect2 + 3;
        if contains(string(data_mapping{ind_row_mapping,col_mapping_video}),'ref')
            %disp("ref");
            if string(videos_vec{ind_video})=='Boxe'
                responses_Boxe_ref = [responses_Boxe_ref ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Boxe_insistence = [responses_Boxe_insistence ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
                responses_Boxe_insistence_ref = [responses_Boxe_insistence_ref ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
            elseif string(videos_vec{ind_video})=='Trike'
                responses_Trike_ref = [responses_Trike_ref ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Trike_insistence = [responses_Trike_insistence ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
                responses_Trike_insistence_ref = [responses_Trike_insistence_ref ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
            end
        elseif contains(string(data_mapping{ind_row_mapping,col_mapping_video}),'tap')
            %disp("tap");
            if string(videos_vec{ind_video})=='Boxe'     
                responses_Boxe_tap = [responses_Boxe_tap ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Boxe_insistence = [responses_Boxe_insistence ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
                responses_Boxe_insistence_tap = [responses_Boxe_insistence_tap ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
            elseif string(videos_vec{ind_video})=='Trike'
                responses_Trike_tap = [responses_Trike_tap ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Trike_insistence = [responses_Trike_insistence ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
                responses_Trike_insistence_tap = [responses_Trike_insistence_tap ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
            end
        elseif contains(string(data_mapping{ind_row_mapping,col_mapping_video}),'insistence') & contains(string(data_mapping{ind_row_mapping,col_mapping_video+2}),'tap')
            %disp("ins tap");
            if string(videos_vec{ind_video})=='Boxe'
                responses_Boxe_insistence = [responses_Boxe_insistence ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Boxe_insistence_tap = [responses_Boxe_insistence_tap ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Boxe_tap = [responses_Boxe_tap ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
            elseif string(videos_vec{ind_video})=='Trike'
                responses_Trike_insistence = [responses_Trike_insistence ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Trike_insistence_tap = [responses_Trike_insistence_tap ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Trike_tap = [responses_Trike_tap ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
            end
        elseif contains(string(data_mapping{ind_row_mapping,col_mapping_video}),'insistence') & contains(string(data_mapping{ind_row_mapping,col_mapping_video+2}),'ref')
            %disp("ins ref");
            if string(videos_vec{ind_video})=='Boxe'
                responses_Boxe_insistence = [responses_Boxe_insistence ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Boxe_insistence_ref = [responses_Boxe_insistence_ref ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Boxe_ref = [responses_Boxe_ref ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
            elseif string(videos_vec{ind_video})=='Trike'
                responses_Trike_insistence = [responses_Trike_insistence ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Trike_insistence_ref = [responses_Trike_insistence_ref ; cell2mat(data_res(ind_user,col_start_effect1:col_end_effect1))];
                responses_Trike_ref = [responses_Trike_ref ; cell2mat(data_res(ind_user,col_start_effect2:col_end_effect2))];
            end
        end
    end
end


%% Response on preference ref insistence

preference_Boxe_ref_insistence = [];
preference_Trike_ref_insistence = [];

for ind_user = user_start+1:nb_total_users+1 % to skip first row with column description
    
    user_id = data_res{ind_user,1};
    ind_row_mapping = find(cell2mat(data_mapping(2:end,1))==user_id)+1;
    
    for ind_video = 1:length(videos_vec)
        col_mapping_video = cols_mapping_video(ind_video);
        col_start_video = cols_start_video(ind_video);
        col_response = col_start_video + 5;      
        if contains(string(data_mapping{ind_row_mapping,col_mapping_video}),'ref')
            if contains(string(data_res{ind_user,col_response}),'La première (la précédente version)')
                preference = 0;%-1;
            else
                preference = 1;
            end
            if string(videos_vec{ind_video})=='Boxe'
                preference_Boxe_ref_insistence = [preference_Boxe_ref_insistence ; preference];
            elseif string(videos_vec{ind_video})=='Trike'
                preference_Trike_ref_insistence = [preference_Trike_ref_insistence ; preference];
            end
        elseif contains(string(data_mapping{ind_row_mapping,col_mapping_video}),'insistence') & contains(string(data_mapping{ind_row_mapping,col_mapping_video+2}),'ref')
            if contains(string(data_res{ind_user,col_response}),'La première (la précédente version)')
                preference = 1;
            else
                preference = 0;%-1;
            end     
            if string(videos_vec{ind_video})=='Boxe'
                preference_Boxe_ref_insistence = [preference_Boxe_ref_insistence ; preference];
            elseif string(videos_vec{ind_video})=='Trike'
                preference_Trike_ref_insistence = [preference_Trike_ref_insistence ; preference];
            end
        end
    end
end


%% Response on preference insistence tap

preference_Boxe_insistence_tap = [];
preference_Trike_insistence_tap = [];

for ind_user = user_start+1:nb_total_users+1 % to skip first row with column description
    
    user_id = data_res{ind_user,1};
    ind_row_mapping = find(cell2mat(data_mapping(2:end,1))==user_id)+1;
    
    for ind_video = 1:length(videos_vec)
        col_mapping_video = cols_mapping_video(ind_video);
        col_start_video = cols_start_video(ind_video);
        col_response = col_start_video + 5;      
        if contains(string(data_mapping{ind_row_mapping,col_mapping_video}),'insistence') & contains(string(data_mapping{ind_row_mapping,col_mapping_video+2}),'tap')
            if contains(string(data_res{ind_user,col_response}),'La première (la précédente version)')
                preference = 0;%-1;
            else
                preference = 1;
            end
            if string(videos_vec{ind_video})=='Boxe'
                preference_Boxe_insistence_tap = [preference_Boxe_insistence_tap ; preference];
            elseif string(videos_vec{ind_video})=='Trike'
                preference_Trike_insistence_tap = [preference_Trike_insistence_tap ; preference];
            end
        elseif contains(string(data_mapping{ind_row_mapping,col_mapping_video}),'tap')
            if contains(string(data_res{ind_user,col_response}),'La première (la précédente version)')
                preference = 1;
            else
                preference = 0;%-1;
            end
            if string(videos_vec{ind_video})=='Boxe'
                preference_Boxe_insistence_tap = [preference_Boxe_insistence_tap ; preference];
            elseif string(videos_vec{ind_video})=='Trike'
                preference_Trike_insistence_tap = [preference_Trike_insistence_tap ; preference];
            end
        end
    end    
end


%% Response on detection of effect, after human-processing of open comments

[num_res, txt_res, data_res] = xlsread('./Resulting_questionnaires/Questionnaire_on_experiments.xlsx');
detection_Boxe = [];
detection_Trike = [];
orderfordetection_Boxe = [];
orderfordetection_Trike = [];
%{
for ind_user = user_start+1:nb_total_users+1 % to skip first row with column description
    
    user_id = data_res{ind_user,1};
    ind_row_mapping = find(cell2mat(data_mapping(2:end,1))==user_id)+1;
    
    for ind_video = 1:length(videos_vec)
        col_mapping_video = cols_mapping_video(ind_video);
        col_start_video = cols_start_video(ind_video);
        if contains(string(data_mapping{ind_row_mapping,col_mapping_video}),'ref')
            col_response = col_start_video + 4;
            order = 2;
        else
            col_response = col_start_video + 4;
            order = 1;
        end
        detection = data_res{ind_user,col_response};
        % fusing 1 and 2
        detection(detection==2)=1;
        if string(videos_vec{ind_video})=='Boxe'
            detection_Boxe = [detection_Boxe ; detection];
            orderfordetection_Boxe = [orderfordetection_Boxe ; order];
        elseif string(videos_vec{ind_video})=='Trike'
            detection_Trike = [detection_Trike ; detection];
            orderfordetection_Trike = [orderfordetection_Trike ; order];
        end
    
    end
end
%}

