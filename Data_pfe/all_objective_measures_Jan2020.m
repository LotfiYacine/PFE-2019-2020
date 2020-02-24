function [duration_hits_Boxe_insistence, duration_hits_Trike_insistence,wall_start_insistence,snap_time_afterwall_insistence,time_disable_wall_Boxe_insistence,time_disable_wall_Trike_insistence,...
    duration_hits_Boxe_tap, duration_hits_Trike_tap,wall_start_tap,snap_time_afterwall_tap,time_disable_wall_Boxe_tap,time_disable_wall_Trike_tap] = all_objective_measures_Jan2020()

videos_vec = {'boxe','Trike'}; 
[num_res, txt_res, data_res] = xlsread('./Resulting_questionnaires/Questionnaire_on_experiments.xlsx');
nb_total_users = size(num_res,1);
%base_path = './test_logs';
base_path = './logs';
[time_wall_Boxe_insistence, time_wall_Trike_insistence,time_disable_wall_Boxe_insistence,time_disable_wall_Trike_insistence,...
    time_wall_Boxe_tap, time_wall_Trike_tap, time_disable_wall_Boxe_tap, time_disable_wall_Trike_tap] = Time_Virtual_Walls()

%%%----------------For VW insistence---------------------------

wall_start_insistence = cell(1,2); wall_start_insistence{1} = time_wall_Boxe_insistence; wall_start_insistence{2} = time_wall_Trike_insistence;
walls_center = 170;
snap_time_afterwall_insistence = cell(1,2); snap_time_afterwall_insistence{1} = time_wall_Boxe_insistence(:,2:size(time_wall_Boxe_insistence,2)); snap_time_afterwall_insistence{2} = time_wall_Trike_insistence(:,2:size(time_wall_Trike_insistence,2));

duration_hits_Boxe_insistence = cell(1,1);
duration_hits_Trike_insistence = cell(1,1);

for ind_user = 1:nb_total_users 
    for ind_video = 1:2 % this loop only for VW, not all videos
        %ind_user, ind_video
        walls_start=wall_start_insistence{ind_video}; snap_time_afterwalls=snap_time_afterwall_insistence{ind_video};
        walls_start=walls_start(ind_user:ind_user,1:size(walls_start,2));snap_time_afterwalls=snap_time_afterwalls(ind_user:ind_user,1:size(snap_time_afterwalls,2));
        for i=1:length(walls_start)
            if(walls_start(i)==0)
                walls_start=walls_start(:,1:i-1);                
                break;
            end           
        end
        %remove all 0 and add default snap (end video)
        for i=1:length(snap_time_afterwalls)
            if(snap_time_afterwalls(i)==0)
                snap_time_afterwalls=snap_time_afterwalls(:,1:i-1);                
                break;
            end           
        end
        snap_time_afterwalls(size(snap_time_afterwalls)+1)=60000;
        
        video_name = videos_vec{ind_video};
        user_foldername = [num2str(ind_user),'/Tests/'];
        user_path = [base_path,'/',user_foldername];
        files = dir(user_path);
        fileIndex = find(~[files.isdir]);

        %% Getting data for in_wall file
        nb_files = 0;
        for i = 1:length(fileIndex)
            file_name = files(fileIndex(i)).name;
            if contains(file_name,video_name) && contains(file_name,'inWall') && contains(file_name,'insistence')
                nb_files = nb_files + 1;
                file_tokeep=files(fileIndex(i));
                %break
            end
        end       
        if nb_files>1 || file_tokeep.bytes ==0
            error('check Lucile')
        end
        file_name = file_tokeep.name;

        data_inwall = readtable([user_path,file_name]);
        data_inwall.Properties.VariableNames={'ClockTime','VideoTime','FoVposition','HeadPosition','LastRotation','LookingOutOfWalls'}; % (only longitude recorded)
        video_time_inwall = data_inwall.VideoTime;
        fov_position_inwall = data_inwall.FoVposition;
        head_position_inwall = data_inwall.HeadPosition;
        last_rotation_inwall = data_inwall.LastRotation;
        flag_outside_inwall = data_inwall.LookingOutOfWalls;

        %% Getting data for head_motion file
        nb_files = 0;
        for i = 1:length(fileIndex)
            file_name = files(fileIndex(i)).name;
            if contains(file_name,video_name) && contains(file_name,'headMotion') && ~contains(file_name,'insistence')
                nb_files = nb_files + 1;
                file_tokeep=files(fileIndex(i));
                %break
            end
        end
        if nb_files>1 || file_tokeep.bytes ==0
            error('check Lucile')
        end
        file_name = file_tokeep.name;

        data_hm = readtable([user_path,file_name]);
        data_hm.Properties.VariableNames={'ClockTime','VideoTime','FoVposition','HeadPosition','LastRotation','Pitch'}; % (only longitude recorded)
        video_time_hm = data_hm.VideoTime;
        fov_position_hm = data_hm.FoVposition;
        head_position_hm = data_hm.HeadPosition;
        last_rotation_hm = data_hm.LastRotation;
        pitch_hm = data_hm.Pitch;
        
        %%         Once WV triggered, need to change fov_position to hm-rot_line-lastrot_beforewall
        %% 	   If upon the VW trigger, fov_position-wallcenter > 30°, 
        %%         do video_time_inwall(1) -> find ind video_time_hm right before, substract 1 from the index
        %%         replace all fov_position and last_rot after the start of the VW, in hm
        %%         stop right before next snap
        
        %% Correcting fov_position_hm and lastRotation when entering each wall
        for ind_wall = 1:length(walls_start)
            [time_start_inwall, ind_start_inwall] = min(abs(video_time_inwall-walls_start(ind_wall)));
            [time_hm, ind_hm] = min(abs(video_time_hm-video_time_inwall(ind_start_inwall)));
            % ind_hm = ind_hm-2; 
            % time_hm = video_time_hm(ind_hm);
            
            span = ind_hm-10:ind_hm+3;
            diff_rot = last_rotation_hm(span+1) - last_rotation_hm(span);
            [max_diff, ind_hop] = max(abs(diff_rot));
            ind_hm = span(ind_hop);
            
            diff_angle = abs(fov_position_hm(ind_hm)-walls_center);
            if diff_angle>180
                diff_angle = abs(-1*(360-diff_angle));
            end
            if diff_angle > 30
                ind_first_hit = ind_start_inwall;
                while ind_first_hit<length(video_time_inwall) && video_time_inwall(ind_first_hit) < snap_time_afterwalls(ind_wall)
                    ind_first_hit = ind_first_hit + 1;
                    if strcmp(flag_outside_inwall{ind_first_hit},'true')
                        break
                    end
                end
                time_end_correction = video_time_inwall(ind_first_hit-1);
                inds = (video_time_hm > video_time_hm(ind_hm+1) & video_time_hm < time_end_correction);
                a=find(video_time_hm > video_time_hm(ind_hm+1)); a=a(1);
                inds(ind_hm+1:a) = 1;
                last_rotation_hm(inds) = last_rotation_hm(inds) + last_rotation_hm(ind_hm);
                indds = (abs(last_rotation_hm)>180);
                sgn_yaw = (last_rotation_hm>0)*2-1;
                last_rotation_hm(indds) = -1*sgn_yaw(indds).*(360-abs(last_rotation_hm(indds)));
        
                fov_position_hm(inds) = fov_position_hm(inds) - last_rotation_hm(ind_hm);
                
                inds = (video_time_inwall > time_hm & video_time_inwall < time_end_correction);
                last_rotation_inwall(inds) = last_rotation_inwall(inds) + last_rotation_hm(ind_hm);
            end
        end
        inds = (abs(fov_position_hm)>180);
        sgn_yaw = (fov_position_hm>0)*2-1;
        fov_position_hm(inds) = -1*sgn_yaw(inds).*(360-abs(fov_position_hm(inds)));
        inds = (abs(last_rotation_inwall)>180);
        sgn_yaw = (last_rotation_inwall>0)*2-1;
        last_rotation_inwall(inds) = -1*sgn_yaw(inds).*(360-abs(last_rotation_inwall(inds)));

        %% Transforming pitch to [-90°,90°]
        pitch_hm = -pitch_hm;  % because -90° facing up
        sgn_pitch = (pitch_hm>0)*2-1;
        c_vec = sgn_pitch * 90;
        inds = (abs(pitch_hm)>90);
        pitch_hm(inds) = c_vec(inds) - (pitch_hm(inds) - c_vec(inds));

        %% Getting wall hit time last rotation before hit
        nb_hits = 0;
        flag_notentered = 0;
        starttime_touch = [];
        endtime_touch = [];
        rotation_before_hit = [];
        for ind_time = 1:length(video_time_inwall)
            time_video = video_time_inwall(ind_time);
            if string(flag_outside_inwall{ind_time})=='true' && flag_notentered == 0
                nb_hits = nb_hits + 1;
                starttime_touch = [starttime_touch, time_video];
                rotation_before_hit = [rotation_before_hit, last_rotation_inwall(max(ind_time-1,1))];
                flag_notentered = 1;
            elseif string(flag_outside_inwall{ind_time})=='false' && flag_notentered == 1
                flag_notentered = 0;
                if time_video-video_time_inwall(ind_time-1)>2000, time_video=video_time_inwall(ind_time-1); end
                endtime_touch = [endtime_touch, time_video];
            end
        end
        if length(endtime_touch) < length(starttime_touch)
            endtime_touch = [endtime_touch, video_time_inwall(end)];
        end

        %% Transforming hm2 with last rotation before hit
        restricted_hm_anytime = fov_position_hm;
        real_yaw_anytime = fov_position_hm;
        for ind_hit = 1:length(starttime_touch)
            ind_hm2 = ((video_time_hm >= starttime_touch(ind_hit)) & (video_time_hm <= endtime_touch(ind_hit)));
            real_yaw_anytime(ind_hm2) = head_position_hm(ind_hm2) - rotation_before_hit(ind_hit);
        end
        inds = (abs(real_yaw_anytime)>180);
        sgn_yaw = (real_yaw_anytime>0)*2-1;
        real_yaw_anytime(inds) = -1*sgn_yaw(inds).*(360-abs(real_yaw_anytime(inds)));

%%%%% end from head_distrib %%%%%%%%%%%%
        
        %% get the time spent in the wall
        duration_hits = endtime_touch - starttime_touch;
        
        %% get how far does the user enter the wall (max of entrance averaged over the different periods)
        depth_touch = zeros(1,nb_hits);
        
        for ind_hit = 1:nb_hits
            time_inds = find(starttime_touch(ind_hit)==video_time_hm) : find(endtime_touch(ind_hit)==video_time_hm);
            diff_longitude=0;
            diff_longitude = real_yaw_anytime(time_inds)-restricted_hm_anytime(time_inds);
            diff_longitude(diff_longitude < -180)=360 + diff_longitude(diff_longitude < -180);
            diff_longitude(diff_longitude > 180)=360 - diff_longitude(diff_longitude > 180);   
            if(isempty(diff_longitude))
                
            else
                depth_touch(ind_hit) = max(abs(diff_longitude)); 
            end
        end
        
        if ind_video == 1
            duration_hits_Boxe_insistence{ind_user} = [duration_hits;starttime_touch;depth_touch];
        else
            duration_hits_Trike_insistence{ind_user} = [duration_hits;starttime_touch;depth_touch];
        end
    end
end

%%%----------------For VW Tap---------------------------

wall_start_tap = cell(1,2); wall_start_tap{1} = time_wall_Boxe_tap; wall_start_tap{2} = time_wall_Trike_tap;
walls_center = 175;
snap_time_afterwall_tap = cell(1,2); snap_time_afterwall_tap{1} = time_wall_Boxe_tap(:,2:size(time_wall_Boxe_tap,2)); snap_time_afterwall_tap{2} = time_wall_Trike_tap(:,2:size(time_wall_Trike_tap,2));
duration_hits_Boxe_tap=cell(1,1);
duration_hits_Trike_tap=cell(1,1);

for ind_user = 1:nb_total_users 
    duration_hits_Boxe_tap{ind_user}=[;];
    duration_hits_Trike_tap{ind_user}=[;];
    for ind_video = 1:2 % this loop only for VW, not all videos
        %ind_user, ind_video
        walls_start=wall_start_tap{ind_video}; snap_time_afterwalls=snap_time_afterwall_tap{ind_video};
        walls_start=walls_start(ind_user:ind_user,1:size(walls_start,2));snap_time_afterwalls=snap_time_afterwalls(ind_user:ind_user,1:size(snap_time_afterwalls,2));
        for i=1:length(walls_start)
            if(walls_start(i)==0)
                walls_start=walls_start(:,1:i-1);                
                break;
            end           
        end
        %remove all 0 and add default snap (end video)
        for i=1:length(snap_time_afterwalls)
            if(snap_time_afterwalls(i)==0)
                snap_time_afterwalls=snap_time_afterwalls(:,1:i-1);                
                break;
            end           
        end
        snap_time_afterwalls(size(snap_time_afterwalls)+1)=60000;
        
        video_name = videos_vec{ind_video};
        user_foldername = [num2str(ind_user),'/Tests/'];
        user_path = [base_path,'/',user_foldername];
        files = dir(user_path);
        fileIndex = find(~[files.isdir]);

        %% Getting data for in_wall file
        nb_files = 0;
        for i = 1:length(fileIndex)
            file_name = files(fileIndex(i)).name;
            if contains(file_name,video_name) && contains(file_name,'inWall') && contains(file_name,'tap')
                nb_files = nb_files + 1;
                file_tokeep=files(fileIndex(i));
                %break
            end
        end       
        if nb_files>1 || file_tokeep.bytes ==0 || nb_files==0
            %error('check Lucile')
        else
            file_name = file_tokeep.name;

            data_inwall = readtable([user_path,file_name]);
            data_inwall.Properties.VariableNames={'ClockTime','VideoTime','FoVposition','HeadPosition','LastRotation','LookingOutOfWalls'}; % (only longitude recorded)
            video_time_inwall = data_inwall.VideoTime;
            fov_position_inwall = data_inwall.FoVposition;
            head_position_inwall = data_inwall.HeadPosition;
            last_rotation_inwall = data_inwall.LastRotation;
            flag_outside_inwall = data_inwall.LookingOutOfWalls;

            %% Getting data for head_motion file
            nb_files = 0;
            for i = 1:length(fileIndex)
                file_name = files(fileIndex(i)).name;
                if contains(file_name,video_name) && contains(file_name,'headMotion') && ~contains(file_name,'tap')
                    nb_files = nb_files + 1;
                    file_tokeep=files(fileIndex(i));
                    %break
                end
            end
            if nb_files>1 || file_tokeep.bytes ==0
                %error('check Lucile')
            end
            file_name = file_tokeep.name;

            data_hm = readtable([user_path,file_name]);
            data_hm.Properties.VariableNames={'ClockTime','VideoTime','FoVposition','HeadPosition','LastRotation','Pitch'}; % (only longitude recorded)
            video_time_hm = data_hm.VideoTime;
            fov_position_hm = data_hm.FoVposition;
            head_position_hm = data_hm.HeadPosition;
            last_rotation_hm = data_hm.LastRotation;
            pitch_hm = data_hm.Pitch;

            %%         Once WV triggered, need to change fov_position to hm-rot_line-lastrot_beforewall
            %% 	   If upon the VW trigger, fov_position-wallcenter > 30°, 
            %%         do video_time_inwall(1) -> find ind video_time_hm right before, substract 1 from the index
            %%         replace all fov_position and last_rot after the start of the VW, in hm
            %%         stop right before next snap

            %% Correcting fov_position_hm and lastRotation when entering each wall
            for ind_wall = 1:length(walls_start)
                [time_start_inwall, ind_start_inwall] = min(abs(video_time_inwall-walls_start(ind_wall)));
                [time_hm, ind_hm] = min(abs(video_time_hm-video_time_inwall(ind_start_inwall)));
                % ind_hm = ind_hm-2; 
                % time_hm = video_time_hm(ind_hm);

                span = ind_hm-10:ind_hm+3;
                diff_rot = last_rotation_hm(span+1) - last_rotation_hm(span);
                [max_diff, ind_hop] = max(abs(diff_rot));
                ind_hm = span(ind_hop);

                diff_angle = abs(fov_position_hm(ind_hm)-walls_center);
                if diff_angle>180
                    diff_angle = abs(-1*(360-diff_angle));
                end
                if diff_angle > 30
                    ind_first_hit = ind_start_inwall;
                    while ind_first_hit<length(video_time_inwall) && video_time_inwall(ind_first_hit) < snap_time_afterwalls(ind_wall)
                        ind_first_hit = ind_first_hit + 1;
                        if strcmp(flag_outside_inwall{ind_first_hit},'true')
                            break
                        end
                    end
                    time_end_correction = video_time_inwall(ind_first_hit-1);
                    inds = (video_time_hm > video_time_hm(ind_hm+1) & video_time_hm < time_end_correction);
                    a=find(video_time_hm > video_time_hm(ind_hm+1)); a=a(1);
                    inds(ind_hm+1:a) = 1;
                    last_rotation_hm(inds) = last_rotation_hm(inds) + last_rotation_hm(ind_hm);
                    indds = (abs(last_rotation_hm)>180);
                    sgn_yaw = (last_rotation_hm>0)*2-1;
                    last_rotation_hm(indds) = -1*sgn_yaw(indds).*(360-abs(last_rotation_hm(indds)));

                    fov_position_hm(inds) = fov_position_hm(inds) - last_rotation_hm(ind_hm);

                    inds = (video_time_inwall > time_hm & video_time_inwall < time_end_correction);
                    last_rotation_inwall(inds) = last_rotation_inwall(inds) + last_rotation_hm(ind_hm);
                end
            end
            inds = (abs(fov_position_hm)>180);
            sgn_yaw = (fov_position_hm>0)*2-1;
            fov_position_hm(inds) = -1*sgn_yaw(inds).*(360-abs(fov_position_hm(inds)));
            inds = (abs(last_rotation_inwall)>180);
            sgn_yaw = (last_rotation_inwall>0)*2-1;
            last_rotation_inwall(inds) = -1*sgn_yaw(inds).*(360-abs(last_rotation_inwall(inds)));

            %% Transforming pitch to [-90°,90°]
            pitch_hm = -pitch_hm;  % because -90° facing up
            sgn_pitch = (pitch_hm>0)*2-1;
            c_vec = sgn_pitch * 90;
            inds = (abs(pitch_hm)>90);
            pitch_hm(inds) = c_vec(inds) - (pitch_hm(inds) - c_vec(inds));

            %% Getting wall hit time last rotation before hit
            nb_hits = 0;
            flag_notentered = 0;
            starttime_touch = [];
            endtime_touch = [];
            rotation_before_hit = [];
            for ind_time = 1:length(video_time_inwall)
                time_video = video_time_inwall(ind_time);
                if string(flag_outside_inwall{ind_time})=='true' && flag_notentered == 0
                    nb_hits = nb_hits + 1;
                    starttime_touch = [starttime_touch, time_video];
                    rotation_before_hit = [rotation_before_hit, last_rotation_inwall(max(ind_time-1,1))];
                    flag_notentered = 1;
                elseif string(flag_outside_inwall{ind_time})=='false' && flag_notentered == 1
                    flag_notentered = 0;
                    if time_video-video_time_inwall(ind_time-1)>2000, time_video=video_time_inwall(ind_time-1); end
                    endtime_touch = [endtime_touch, time_video];
                end
            end
            if length(endtime_touch) < length(starttime_touch)
                endtime_touch = [endtime_touch, video_time_inwall(end)];
            end

            %% Transforming hm2 with last rotation before hit
            restricted_hm_anytime = fov_position_hm;
            real_yaw_anytime = fov_position_hm;
            for ind_hit = 1:length(starttime_touch)
                ind_hm2 = ((video_time_hm >= starttime_touch(ind_hit)) & (video_time_hm <= endtime_touch(ind_hit)));
                real_yaw_anytime(ind_hm2) = head_position_hm(ind_hm2) - rotation_before_hit(ind_hit);
            end
            inds = (abs(real_yaw_anytime)>180);
            sgn_yaw = (real_yaw_anytime>0)*2-1;
            real_yaw_anytime(inds) = -1*sgn_yaw(inds).*(360-abs(real_yaw_anytime(inds)));

    %%%%% end from head_distrib %%%%%%%%%%%%

            %% get the time spent in the wall
            duration_hits = endtime_touch - starttime_touch;

            %% get how far does the user enter the wall (max of entrance averaged over the different periods)
            depth_touch = zeros(1,nb_hits);

            for ind_hit = 1:nb_hits
                time_inds = find(starttime_touch(ind_hit)==video_time_hm) : find(endtime_touch(ind_hit)==video_time_hm);
                diff_longitude=0;
                diff_longitude = real_yaw_anytime(time_inds)-restricted_hm_anytime(time_inds);
                diff_longitude(diff_longitude < -180)=360 + diff_longitude(diff_longitude < -180);
                diff_longitude(diff_longitude > 180)=360 - diff_longitude(diff_longitude > 180);   
                if(isempty(diff_longitude))
                   
                else
                    depth_touch(ind_hit) = max(abs(diff_longitude)); 
                end
            end

            if ind_video == 1
                duration_hits_Boxe_tap{ind_user} = [duration_hits;starttime_touch;depth_touch];
            else
                duration_hits_Trike_tap{ind_user} = [duration_hits;starttime_touch;depth_touch];
            end
        end
    end
end
disp("bob")






        
        
