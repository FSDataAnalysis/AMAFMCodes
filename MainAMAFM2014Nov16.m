clear all;
close all;
clc;


%%%%% Check if you are in the right folder %%%%%%

Main_file_find= dir(fullfile('MainAMAFM2014Nov16.m') );
Main_file_find_name_cell = strcat({Main_file_find.name});

if isempty(Main_file_find_name_cell{1})==1
    error('Wrong directory. Please move to the directory with mainAMAFM'); 
end



%%%% Question: 1. Processing files from a large file into small?
%%%% Question: 2. Use the Edis statistics at adhesion point?
%%%% Question: 3. Use the FAd and work of adhesion statistics at adhesion point?
%%%% Question: 4. Use the Young Modulus statistics 
%%%% Question: 5. Remove outliers for mean and std. 

prompt_main= {'Process Files (0/1):', 'Edis(FAD) (stats)(0/1):', 'FAD/Work AD (stats) (0/1):', ...
    'Young M (stats) (0/1):', 'Remove outliers before stats (0/1):', 'Young M-Find d=0 (DMT) :', ...
    'Minimum DMT force:', 'Break if error (0/1):'};

dlg_title_main='Main';
num_lines=1;
default_main={'1','1','1','1','1', '1', '0.4','0'};
answer_main=inputdlg(prompt_main,dlg_title_main,num_lines,default_main);

ParentDirMain=pwd;

ProcessFiles_main= str2double(answer_main(1));
stats_Edis= str2double(answer_main(2));
Stats_FAD= str2double(answer_main(3));
Stats_YounM= str2double(answer_main(4));
Stats_ROutliers= str2double(answer_main(5));
find_d_is_zero_DMT=str2double(answer_main(6));
DUMB_cut_off_force=str2double(answer_main(7));
Cut_off_force=DUMB_cut_off_force;
Break_error=str2double(answer_main(8));

save_final_vectors=1;
%%%% folder where figures will be saved
save_processed=strcat(ParentDirMain,'\StatisticsAttractive');
cd(save_processed);
if exist('ION', 'dir')
    rmdir('ION', 's');  %delete everything in it!
end
mkdir('ION');
cd(ParentDirMain);

if exist('SAVED_DATA', 'dir')
    rmdir('SAVED_DATA', 's');  %delete everything in it!
end
mkdir('SAVED_DATA');

%% In the SAVED_DATA directory all the data will be saved for each file
save_all_data=strcat(ParentDirMain,'\SAVED_DATA'); 


%%%%%% delete files of MAT in main code %%%%%%%%%%%%%%

save_mat_path=strcat(ParentDirMain,'\MainCode');
cd(save_mat_path);
if exist('MAT_DATA', 'dir')
    rmdir('MAT_DATA', 's');  %delete everything in it!
end
cd(ParentDirMain);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


excel_file_Edis = 'mydata_Edis.xlsx';
excel_file_dFAD = 'mydata_dFAD.xlsx';
excel_file_YM = 'mydata_YM.xlsx';

delete(excel_file_Edis, excel_file_dFAD, excel_file_YM);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save data_main;

%%%%%%%%%%% Main END %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;

%%%%%%%% Details for processing forces, i.e. cantilever parameters %%%%%%%%%%%%%%%%%%%%%%

prompt= {'Spring Constant:','ThermalQ:','Frequency:','Crop at:','Smoothing Coefficient:','Elastic Modulus? 1 or 0:', ...
    'InVolts:', 'Tip Radius: ', 'remove_start:', 'remove_end:', 'subtract end YM:', 'subtract start YM:'};


dlg_title='Cantilever Inputs and processing';
num_lines=1;
default={'','','','2','0.02','1', '40', '7e-9', '150', '50', '20', '20'};
answer=inputdlg(prompt,dlg_title,[1, length(dlg_title)+40], default); 

ParentDirMain=pwd;
Folder_MainCode=char(sprintf('%s',ParentDirMain, '\MainCode'));  

save data_forces;

save('data_main', 'Folder_MainCode','-append');

%%%%%%%%%%% Cantilever Info END %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;

%%%%%%%%%%% Process files ? %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load data_main;

if ~ProcessFiles_main==0

    clear all;
    clc;
    
    prompt= {'Extension (0) / Retraction (1):','Organize columns (0/1):'};
    dlg_title='Process Raw Files';  %%% Inputs: Organize 1 only if "Cypher shift collected
%     num_lines=1;
    default={'0', '1'};
    answer=inputdlg(prompt,dlg_title,[1, length(dlg_title)+40], default); 

    ParentDirMain=pwd;
    Folder_ProcessF=char(sprintf('%s',ParentDirMain, '\ProcessFiles')); 

    save data_process_files;
    
    save('data_main', 'Folder_ProcessF','-append');

end
    


%%%%%%%%%%% Process Files END %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;

%%%%%%%%%%% FAD, Work of Adhesion %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load data_main;

if Stats_FAD==1
    

    prompt= {'Multiple ref:','Number of points:', 'Initial:','Final:'};
    dlg_title='Metrics dFAD/Work of Adhesion';
    % num_lines=1;
    default={'0','2', '0.05','0.8',};
    answer=inputdlg(prompt,dlg_title,[1, length(dlg_title)+40], default); 

    
    Folder_Stats_dFAD=char(sprintf('%s',ParentDirMain, '\StatisticsAttractive')); 

    save data_stats_dFAD;
    
    save('data_main', 'Folder_Stats_dFAD','-append');

end

%%%%%%%%%%% End FAD, Work of Adhesion %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% START PROCESSING FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load data_main;

%%%% if ProcessFiles_main==1 then it has to "split the files" otherwise
%%%% copy paset directly into directory inside Statistics foleder

Folder_RAWFILES=char(sprintf('%s',ParentDirMain, '\ADDFILES'));

if ~ProcessFiles_main==0     
    
    RawFileName = dir(fullfile(Folder_RAWFILES,'*.txt') );
    RawFileName_path = strcat(Folder_RAWFILES, filesep, {RawFileName.name});
    
    [pathstr_is, name_is, ext_is]=fileparts(RawFileName_path{1});
    raw_file_name=name_is;

    RawFileName_path_char=char(RawFileName_path);
    dumb_file_path=char(sprintf('%s',Folder_ProcessF, '\', raw_file_name, '.txt'));
    
    copyfile(RawFileName_path_char, dumb_file_path, 'f');
    
    
    %%%%% load answers for process files %%%%%%%%%
    load data_process_files;
    
    
    cd(Folder_ProcessF);
    RedoFiles;    %%%% this will crop the files as needed 
  
    %%%% file names to be copied %%%%
    
    new_file_names_foo = dir(fullfile(Folder_ProcessF,'*.txt') );
    new_file_names = strcat(Folder_ProcessF, filesep, {new_file_names_foo.name});
    
    %%%% move files to statistics folder (ION) for computation of main code
    dumb_computation_path=char(sprintf('%s',ParentDirMain, '\StatisticsAttractive\ION'));
    
    
    for jjj=1:length(new_file_names)
        
        [pathstr_foo, name_foo, ext_foo]=fileparts(new_file_names{jjj});
        foo_name=name_foo;
        
        destination_foo=char(sprintf('%s',dumb_computation_path, '\', foo_name, '.txt'));
        
        movefile(new_file_names{jjj},destination_foo,'f');
    
    end
    
    cd(ParentDirMain); 

    %%%%% The files should be properly arranged now to be computed by main
    %%%%% code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else  %%% Do not process files, i.e. it is added file by file 
    
    
    current_dir_now_is=pwd;
    
    %%% ensure you are in right folder, i.e. main code 
    if ~strcmp(current_dir_now_is, Folder_MainCode)        
        cd(Folder_MainCode);
    end
    
    cd(Folder_RAWFILES);
    %%%% find txt files %%%%%%%%%%%%%%
    add_files_raw = dir(fullfile('*.txt') );
    %%%%% Get names
    add_files_raw_names = strcat({add_files_raw.name});

    number_files_add=length(add_files_raw_names);
    
    computation_folder=char(sprintf('%s',ParentDirMain, '\StatisticsAttractive\ION'));


    for fff=1:number_files_add
        copyfile(add_files_raw_names{fff},computation_folder, 'f');
    end

    cd(ParentDirMain);  

end

%%%% INDICATE PATH to read files AND read files  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
clc;

load data_main;   %% main details by user
load data_forces; %% main answers by user, i.e. cantilever etc. 

fPath = char(sprintf('%s',ParentDirMain, '\StatisticsAttractive\ION'));
if fPath==0, error('no folder selected'), end

fNames = dir(fullfile(fPath,'*.txt') );
fNames = strcat(fPath, filesep, {fNames.name});

%%%% START COMPUTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


cd(Folder_MainCode);
MainForces;   % This caculates forces etc. 

cd(ParentDirMain);
save ('data_main', 'flag_failed_F_Adhesion', '-append');
cd(Folder_MainCode);

%%%% END COMPUTATION FORCES of MAIN CODE ------- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% calculate Edis (at adhesion, FAD, etc.) 

if stats_Edis==1
    
    AveragesVirial_Edis_Etc;
    
    cd(ParentDirMain);
    foo_save_data = sprintf('Data_Energy_FAD_Virial');
    save (foo_save_data, 'Adhesion_M','Edis_crop_M', 'Edis_M', 'Virial_M',  'Edis_adhesion_M','Virial_adhesion_M'); 
    
    if isequal(size(Adhesion_M), size(Edis_crop_M), size(Edis_M), ...
        size(Virial_M), size(Edis_adhesion_M), size(Virial_adhesion_M)) 
        
        my_data_Edis_etc=[Adhesion_M,Edis_crop_M, Edis_M, Virial_M, Edis_adhesion_M,Virial_adhesion_M];
        col_names_Edis={'Adhesion_M','Edis_crop_M', 'Edis_M', 'Virial_M',  'Edis_adhesion_M','Virial_adhesion_M'};
        
        xlswrite(excel_file_Edis,col_names_Edis, 'Edis');  
        xlswrite(excel_file_Edis,my_data_Edis_etc, 'Edis', 'A2');
 
    else
     
        col_names={'Failed to save data to excel, check data_file'};
        status=0;
        xlswrite(excel_file_Edis,col_names,'Edis');
        xlswrite(excel_file_Edis,status,'Edis', 'A2');
   
    end

else
    
     cd(ParentDirMain);
end

%%%%%% calculate E Modulus  (stats, etc) 

if Stats_YounM==1
    
    current_dir_is=pwd;
    
    %%% ensure you are in right folder, i.e. main code 
    if ~strcmp(current_dir_is, Folder_MainCode)        
        cd(Folder_MainCode);
    end
    
    AveragesElasticity;
    cd(ParentDirMain);
    
    foo_save_data = sprintf( 'Data_Young_Modulus');
    dumb_R=str2double(answer(8));
    
    R_is=(ones(1,length(EE_M_AL))*dumb_R)';
    
    save (foo_save_data, 'EE_M_NN', 'R_is', 'flag_correct_YM_NN', 'EE_M_AL', 'EE_M_NN_single', ...
        'flag_complex_NN', 'flag_complex_single_NN', 'correction_Indentation_NN'); 
    
    
    
    if isequal(size(EE_M_NN), size(R_is), size(flag_correct_YM_NN), ...
        size(EE_M_AL), size(EE_M_NN), size(flag_complex_NN), size(flag_complex_single_NN), size(correction_Indentation_NN)) 
    
        my_data_YM=[EE_M_NN, EE_M_NN_single, EE_M_AL,  R_is, ...
            flag_correct_YM_NN, flag_complex_NN, flag_complex_single_NN, correction_Indentation_NN ];
        
        
        col_names_YM={'Young Modulus (GPa)', 'Young M (GPa) Single fit', 'Estimation YM (GPa)', ...
            'Tip radius', 'Success DMT', 'Complex DMT', 'Complex single', 'Indentation Correction'};

        xlswrite(excel_file_YM, col_names_YM, 'YM' );   
        xlswrite(excel_file_YM, my_data_YM, 'YM', 'A2');
    
    else
        
        col_names={'Failed to save data to excel, check data_file'};
        status=0;
        xlswrite(excel_file_YM,col_names, 'YM');
        xlswrite(excel_file_YM,status, 'YM', 'A2');
        
    end

else
    
     cd(ParentDirMain);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Move Mat data in main code into  %%%%%%%%%%%%%%%%%%%%%%%%%%

current_dir_now_is=pwd;
    
%%% ensure you are in right folder, i.e. main code 
if ~strcmp(current_dir_now_is, Folder_MainCode)        
    cd(Folder_MainCode);
end

%%%% find mat files %%%%%%%%%%%%%%
Mat_files_raw = dir(fullfile('*.mat') );
%%%%% Get names
Mat_files_raw_names = strcat({Mat_files_raw.name});

number_files_mat=length(Mat_files_raw_names);

Folder_MainCode_MAT=char(sprintf('%s',Folder_MainCode, '\MAT_DATA'));  

for fff=1:number_files_mat
    movefile(Mat_files_raw_names{fff},Folder_MainCode_MAT);
end

cd(ParentDirMain);    

%%%% END COMPUTATION FORCES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;
%%%% Compute Stats for dFAD, work of adhesion etc. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load data_main;   %% main details by user


if Stats_FAD==1

    load data_stats_dFAD; %% answers by user for stats
    
    cd(Folder_Stats_dFAD);   %% move to folder where file for statistics is
    FiguresProcessing2014;   %% do stats
    
    cd(ParentDirMain);
    
    number_of_points=dumb_loop;
   
    foo_n=size(Matrix_values);
    
    dd_number_files=foo_n(1);
    
    M_dFAD=[];
    
    number_of_files_odd=mod(number_of_points,2);
    
    if number_of_files_odd==0
        numb_points_foo=(number_of_points/2);
    
    elseif number_of_files_odd==1
        numb_points_foo=((number_of_points-1)/2);
    else
        error('Mistake in number of files at Main code Line 289');
    end
        
    for iii=1:numb_points_foo
        
        k=1+(iii-1)*2;
        New_col_1=(ones(1, dd_number_files)*CL_vector(k))';
        New_col_2=(ones(1, dd_number_files)*CL_vector(k+1))';
        dumb_1_m=[Matrix_values(:,:,k) New_col_1];
        dumb_2_m=[Matrix_values(:,:,k+1) New_col_2];
        
        M_dFAD_dumb=cat(1, dumb_1_m ,dumb_2_m);
        M_dFAD=[M_dFAD; M_dFAD_dumb];
    end
    
    if number_of_files_odd==1
    
        New_col_3=(ones(1, dd_number_files)*CL_vector(end))';
        dumb_3_m=[Matrix_values(:,:,end) New_col_3];
        M_dFAD=[M_dFAD; dumb_3_m];
    end
    
    M_dFAD_real=M_dFAD;
    M_dFAD_real(any(isnan(M_dFAD),2),:) = [];
    
    if ~isempty(M_dFAD_real) 
        
        col_names={'Force Adhesion','Work of Adhesion', 'dFAD', 'Percentage'};
    
        xlswrite(excel_file_dFAD, col_names, 'dAF'); 
        xlswrite(excel_file_dFAD, M_dFAD_real, 'dAF', 'A2');
         
    else
                
        col_names={'Failed to save data to excel, check data_file'};
        status=0;
        xlswrite(excel_file_dFAD,col_names,1);
        xlswrite(excel_file_dFAD,status,'A2');       
    end 
    
    
    save ('data_stats_dFAD', 'M_dFAD','M_dFAD_real', '-append'); 
end


%%%% END Stats FAD  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% add files to data save files folder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%% find mat files %%%%%%%%%%%%%%
Mat_files_raw_data = dir(fullfile('*.mat') );
%%%%% Get names
Mat_files_raw_names_data = strcat({Mat_files_raw_data.name});

number_files_mat=length(Mat_files_raw_names_data);


for fff=1:number_files_mat
    movefile(Mat_files_raw_names_data{fff},save_all_data);
end

