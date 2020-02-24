function [time_wall_Boxe_insistence, time_wall_Trike_insistence,time_disable_wall_Boxe_insistence,time_disable_wall_Trike_insistence,...
    time_wall_Boxe_tap, time_wall_Trike_tap, time_disable_wall_Boxe_tap, time_disable_wall_Trike_tap] = Time_Virtual_Walls()
       
videos_vec = {'boxe','Trike'}; 
[num_res, txt_res, data_res] = xlsread('./Resulting_questionnaires/Questionnaire_on_experiments.xlsx');
nb_total_users = size(num_res,1);
%base_path = './test_logs';
base_path = './logs';

%%-------insitence---------------------------------------------
time_wall_Boxe_insistence=[];
time_wall_Trike_insistence=[];
time_disable_wall_Boxe_insistence=[];
time_disable_wall_Trike_insistence=[];
global ind_Files;
global nb_VW;
for ind_user = 1:nb_total_users
    %add default wall
    time_wall_Boxe_insistence(ind_user,1)=7000;
    time_wall_Trike_insistence(ind_user,1)=7000;
    
    for ind_video =1:2
        video_name = videos_vec{ind_video};
        user_foldername = [num2str(ind_user),'/Tests/'];
        user_path = [base_path,'/',user_foldername];
        files = dir(user_path);
        fileIndex = find(~[files.isdir]);
        nb_files = 0;
        for i = 1:length(fileIndex)
            file_name = files(fileIndex(i)).name;
            if contains(file_name,video_name) && contains(file_name,'TimeInside') && contains(file_name,'insistence')
                nb_files = nb_files + 1;
                file_tokeep=files(fileIndex(i));
                %break
            end
        end
        if nb_files>1 || file_tokeep.bytes ==0
            error('check Yacine')
        else   
            file_name = file_tokeep.name;            
            data_inwall = readtable([user_path,file_name]);
            data_inwall.Properties.VariableNames={'Time','TimeInsideVirtualWall','CurrentVideoTime','UserLookingOutOfWallsLimits','TimeOutSideVirtualWall'}; % (only longitude recorded)
            time = data_inwall.Time;
            TimeInsideVirtualWall = data_inwall.TimeInsideVirtualWall;
            CurrentVideoTime = data_inwall.CurrentVideoTime;
            UserLookingOutOfWallsLimits = data_inwall.UserLookingOutOfWallsLimits;
            TimeOutSideVirtualWall = data_inwall.TimeOutSideVirtualWall;

            nb_VW=1; ind_Files=1;
            while( ind_Files <= size(TimeOutSideVirtualWall,1))    
                if(TimeOutSideVirtualWall(ind_Files)>3900 && TimeOutSideVirtualWall(ind_Files+1)==0)
                    nb_VW=nb_VW+1;
                    if ind_video == 1
                        time_wall_Boxe_insistence(ind_user,nb_VW) = CurrentVideoTime(ind_Files);                     
                    else                        
                        time_wall_Trike_insistence(ind_user,nb_VW)= CurrentVideoTime(ind_Files);      
                    end          
                end   
                ind_Files=ind_Files+1;
            end 
            if ind_video == 1
                nb_hits_Boxe(ind_user) = nb_VW;               
            else
                nb_hits_Trike(ind_user) = nb_VW;
            end
            
            nb_VW=0; ind_Files=1;
            while( ind_Files <= size(TimeOutSideVirtualWall,1))    
                if(TimeInsideVirtualWall(ind_Files)>3900 && TimeInsideVirtualWall(ind_Files+1)==0)
                    nb_VW=nb_VW+1;
                    if ind_video == 1
                        time_disable_wall_Boxe_insistence(ind_user,nb_VW) = CurrentVideoTime(ind_Files);                            
                    else                        
                        time_disable_wall_Trike_insistence(ind_user,nb_VW)= CurrentVideoTime(ind_Files);      
                    end          
                end   
                ind_Files=ind_Files+1;
            end 
            if ind_video == 1
                nb_disable_Boxe(ind_user) = nb_VW;               
            else
                nb_disable_Trike(ind_user) = nb_VW;
            end
        end
    end    
end
time_disable_wall_Boxe_insistence(:,size(time_disable_wall_Boxe_insistence,2)+1)=0;
time_disable_wall_Trike_insistence(:,size(time_disable_wall_Trike_insistence,2)+1)=0;
time_disable_wall_Boxe_insistence=changem(time_disable_wall_Boxe_insistence,[60000],[0]);
time_disable_wall_Trike_insistence=changem(time_disable_wall_Trike_insistence,[60000],[0]);
disp(nb_disable_Boxe)
disp(nb_disable_Trike)

%%-------tap---------------------------------------------
time_wall_Boxe_tap=[];
time_wall_Trike_tap=[];
time_disable_wall_Boxe_tap=zeros(nb_total_users,1);
time_disable_wall_Trike_tap=zeros(nb_total_users,1);
global ind_Files;
global nb_VW;
for ind_user = 1:nb_total_users
    %add default wall
    time_wall_Boxe_tap(ind_user,1)=7000;
    time_wall_Trike_tap(ind_user,1)=7000;
    
    for ind_video =1:2
        video_name = videos_vec{ind_video};
        user_foldername = [num2str(ind_user),'/Tests/'];
        user_path = [base_path,'/',user_foldername];
        files = dir(user_path);
        fileIndex = find(~[files.isdir]);
        nb_files = 0;
        for i = 1:length(fileIndex)
            file_name = files(fileIndex(i)).name;
            if contains(file_name,video_name) && contains(file_name,'TimeInside') && contains(file_name,'tap')
                nb_files = nb_files + 1;
                file_tokeep=files(fileIndex(i));
                %break
            end
        end
        if nb_files>1 || file_tokeep.bytes ==0 || nb_files==0
            %error('check Yacine')
        else   
            file_name = file_tokeep.name;            
            data_inwall = readtable([user_path,file_name]);
            data_inwall.Properties.VariableNames={'Time','TimeInsideVirtualWall','CurrentVideoTime','UserLookingOutOfWallsLimits','TimeOutSideVirtualWall'}; % (only longitude recorded)
            time = data_inwall.Time;

            TimeOutSideVirtualWall = data_inwall.TimeOutSideVirtualWall;

            nb_VW=1; ind_Files=1;
            while( ind_Files < size(TimeOutSideVirtualWall,1))    
                if(TimeOutSideVirtualWall(ind_Files)>3900 && TimeOutSideVirtualWall(ind_Files+1)==0)
                    nb_VW=nb_VW+1;
                    if ind_video == 1
                        time_wall_Boxe_tap(ind_user,nb_VW) = CurrentVideoTime(ind_Files);                           
                    else                        
                        time_wall_Trike_tap(ind_user,nb_VW)= CurrentVideoTime(ind_Files);      
                    end          
                end   
                ind_Files=ind_Files+1;
            end 
            if ind_video == 1
                nb_hits_Boxe(ind_user) = nb_VW;               
            else
                nb_hits_Trike(ind_user) = nb_VW;
            end
            nb_files = 0;
            for i = 1:length(fileIndex)
                file_name = files(fileIndex(i)).name;
                if contains(file_name,video_name) && contains(file_name,'InterruptedVirtualWall') && contains(file_name,'tap')
                    nb_files = nb_files + 1;
                    file_tokeep=files(fileIndex(i));
                    %break
                end
            end
            
            file_name = file_tokeep.name;            
            data_interruptedVirtualWall = readtable([user_path,file_name],'ReadVariableNames',false);          
            data_interruptedVirtualWall.Properties.VariableNames={'Time','TimeVW','TimeStartVW','ExpectedDuration','EndVideoTime','TimeVWstop','HeadPosition'}; % (only longitude recorded)
            time = data_interruptedVirtualWall.Time;
            time_VW_stop = data_interruptedVirtualWall.TimeVWstop;
            nb_VW=0; ind_Files=1;
            while( ind_Files <= size(time,1))               
                    nb_VW=nb_VW+1;
                    if ind_video == 1
                        time_disable_wall_Boxe_tap(ind_user,nb_VW) = time_VW_stop(ind_Files);                       
                    else                        
                        time_disable_wall_Trike_tap(ind_user,nb_VW)= time_VW_stop(ind_Files);
                    end 
                ind_Files=ind_Files+1;
            end 
            if ind_video == 1
                nb_disable_Boxe(ind_user) = nb_VW;               
            else
                nb_disable_Trike(ind_user) = nb_VW;
            end            
        end
    end    
end
time_disable_wall_Boxe_tap(:,size(time_disable_wall_Boxe_tap,2)+1)=0;
time_disable_wall_Trike_tap(:,size(time_disable_wall_Trike_tap,2)+1)=0;
time_disable_wall_Boxe_tap=changem(time_disable_wall_Boxe_tap,[60000],[0]);
time_disable_wall_Trike_tap=changem(time_disable_wall_Trike_tap,[60000],[0]);
disp(nb_disable_Boxe)
disp(nb_disable_Trike)


