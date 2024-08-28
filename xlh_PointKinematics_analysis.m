

% Loop Through Folders: The function iterates through each folder specified in the folders array.
% Run OpenSim Analysis: For each folder, it updates the XML configuration file, runs the OpenSim analysis tool using a system command, and then reads the output .sto file.
% Save the Structure: The results are stored in the structure S, which is saved to a .mat file named metric.mat in the corresponding results folder using the save function.
% Paths and Filenames: The function dynamically constructs paths based on the root directory and folders. The use of fullfile ensures compatibility across different operating systems.

function analyze_PointKinematics()
    %% Get paths for later use
    [pathHere,~,~] = fileparts(mfilename('fullpath'));


    % Define the folders corresponding to different levels of hip assistance
    folders = {'_0hipAssistance', '_10hipAssistance', '_20hipAssistance', '_30hipAssistance', '_40hipAssistance', ...
               '_50hipAssistance', '_60hipAssistance', '_70hipAssistance', ...
               '_80hipAssistance', '_90hipAssistance'};

%     folders = {'_10hipAssistance'}

    %% Define the root directory containing the results
    root_folder =  fullfile(pathHere, 'PredSimResults\DHondt_2023_3seg_0.1strengthMS_test_back');
    
    % Define the model folder path
    Model_folder = fullfile(pathHere, 'Subjects');
    
    % Define the path to the OpenSim model file
    osim_path = [Model_folder '\DHondt_2023_3seg\DHondt_2023_3seg.osim'];

    xmlFile = 'PredSimResults\config_pointKinematics.xml';
    xmlFilePath = fullfile(pathHere, xmlFile);

    % Analyze motion data for each folder
    for index = 1:length(folders)
        % Construct the full path to the results folder
        Results_folder = fullfile(root_folder, folders{index});
        
        % Construct the full path to the motion file (.mot)
        motFile = fullfile(Results_folder, 'DHondt_2023_3seg_v1.mot');

        % Display a prompt indicating the current analysis folder
        disp(['Running PointKinematics analysis for: ', folders{index}]);
        disp(['motion file: ', motFile]);

        %% Run the analysis for the current folder
        modifyBodyNameInXML(xmlFilePath, 'toes_l')
        modifyPointInXML(xmlFilePath, [0.014239,0.0220445,-0.00295239])
        modifyCoordinatesFileInXML(xmlFilePath, motFile)
        modifyResultsDirectoryInXML(xmlFilePath, Results_folder)
    
        runInCmd(['opensim-cmd run-tool ' xmlFile])

        stoFile = fullfile(Results_folder, '3-segment_foot_model_fixed_knee_axis_PointKinematics_footclearance_pos.sto');
        data = readtable(stoFile, 'FileType', 'text');
        S.toes_l.time = data.time;
        S.toes_l.xyz = [data.state_0, data.state_1,data.state_2];
        save(fullfile(Results_folder, 'metric.mat'), 'S');


        % Display a prompt indicating completion of the current folder's analysis
        disp(['Completed analysis for: ', folders{index}]);
    end
end


function test()
    %% Get paths for later use
    [pathHere,~,~] = fileparts(mfilename('fullpath'));
    [pathRepo,~,~] = fileparts(pathHere);
    [pathRepoFolder,~,~] = fileparts(pathRepo);

    xmlFile = 'PredSimResults\config_pointKinematics.xml';

    xmlFilePath = fullfile(pathHere, xmlFile);

    modifyBodyNameInXML(xmlFilePath, 'toes_l')

    modifyPointInXML(xmlFilePath, [0.014239,0.0220445,-0.00295239])

    modifyCoordinatesFileInXML(xmlFilePath, 'DHondt_2023_3seg_0.1strengthMS_test_back/_20hipAssistance/DHondt_2023_3seg_v1.mot')
    
    modifyResultsDirectoryInXML(xmlFilePath, 'DHondt_2023_3seg_0.1strengthMS_test_back/_20hipAssistance')

    runInCmd(['opensim-cmd run-tool ' xmlFile])
end

% modifyBodyNameInXML(xmlFilePath, 'dgfsgds')
function modifyBodyNameInXML(xmlFilePath, newBodyName)
    % Read the XML file into a string
    xmlText = fileread(xmlFilePath);
    
    % Define the pattern to match the <body_name> tag content
    pattern = '<body_name>.*?</body_name>';
    
    % Define the replacement string with the new body name
    replacement = ['<body_name>', newBodyName, '</body_name>'];
    
    % Replace the old body name content with the new one
    updatedXmlText = regexprep(xmlText, pattern, replacement);
    
    % Write the updated text back to the XML file
    fid = fopen(xmlFilePath, 'w');
    if fid == -1
        error('Cannot open file for writing: %s', xmlFilePath);
    end
    fwrite(fid, updatedXmlText, 'char');
    fclose(fid);
    
    fprintf('Modified the <body_name> content to "%s" in %s\n', newBodyName, xmlFilePath);
end

% modifyPointInXML(xmlFilePath, [2,3,5])
function modifyPointInXML(xmlFilePath, pointArray)
    % Ensure the input is a numeric array with three elements
    if numel(pointArray) ~= 3 || ~isnumeric(pointArray)
        error('Input must be a numeric array with three elements, e.g., [1, 2, 3].');
    end
    
    % Convert the pointArray to a string in the format "x y z"
    newPointString = sprintf('%.8f %.8f %.8f', pointArray(1), pointArray(2), pointArray(3));
    
    % Read the XML file into a string
    xmlText = fileread(xmlFilePath);
    
    % Define the pattern to match the <point> tag content
    pattern = '<point>.*?</point>';
    
    % Define the replacement string with the new point values
    replacement = ['<point>', newPointString, '</point>'];
    
    % Replace the old point content with the new one
    updatedXmlText = regexprep(xmlText, pattern, replacement);
    
    % Write the updated text back to the XML file
    fid = fopen(xmlFilePath, 'w');
    if fid == -1
        error('Cannot open file for writing: %s', xmlFilePath);
    end
    fwrite(fid, updatedXmlText, 'char');
    fclose(fid);
    
    fprintf('Modified the <point> content to "%s" in %s\n', newPointString, xmlFilePath);
end


function modifyCoordinatesFileInXML(xmlFilePath, newCoordinatesFile)
    % Read the XML file into a string
    xmlText = fileread(xmlFilePath);
    
    % Define the pattern to match the <coordinates_file> tag content
    pattern = '<coordinates_file>.*?</coordinates_file>';
    
    % Define the replacement string with the new coordinates file
    replacement = ['<coordinates_file>', newCoordinatesFile, '</coordinates_file>'];
    replacement = strrep(replacement, '\', '\\');   % \ is special character
    
    % Replace the old coordinates file content with the new one
    updatedXmlText = regexprep(xmlText, pattern, replacement);
    
    % Write the updated text back to the XML file
    fid = fopen(xmlFilePath, 'w');
    if fid == -1
        error('Cannot open file for writing: %s', xmlFilePath);
    end
    fwrite(fid, updatedXmlText, 'char');
    fclose(fid);
    
    fprintf('Modified the <coordinates_file> content to "%s" in %s\n', newCoordinatesFile, xmlFilePath);
end

function modifyResultsDirectoryInXML(xmlFilePath, newResultsDirectory)
    % MODIFYRESULTSDIRECTORYINXML Modifies the string between 
    % <results_directory> </results_directory> in the specified XML file.
    %
    %   modifyResultsDirectoryInXML(xmlFilePath, newResultsDirectory)
    %
    % Inputs:
    %   xmlFilePath - Path to the XML file to be modified.
    %   newResultsDirectory - New string to be placed between the <results_directory> tags.
    
    % Read the XML file into a string
    xmlText = fileread(xmlFilePath);
    
    % Define the pattern to match the <results_directory> tag content
    pattern = '<results_directory>.*?</results_directory>';
    
    % Define the replacement string with the new results directory
    replacement = ['<results_directory>', newResultsDirectory, '</results_directory>'];
    replacement = strrep(replacement, '\', '\\')
    
    % Replace the old results directory content with the new one
    updatedXmlText = regexprep(xmlText, pattern, replacement);
    
    % Write the updated text back to the XML file
    fid = fopen(xmlFilePath, 'w');
    if fid == -1
        error('Cannot open file for writing: %s', xmlFilePath);
    end
    fwrite(fid, updatedXmlText, 'char');
    fclose(fid);
    
    fprintf('Modified the <results_directory> content to "%s" in %s\n', newResultsDirectory, xmlFilePath);
end

function [status, cmdout] = runInCmd(command)
    % RUNINCMD Executes a given command in the system's command prompt.
    %
    %   [status, cmdout] = runInCmd(command)
    %
    % Inputs:
    %   command - A string containing the command to be executed in CMD.
    %
    % Outputs:
    %   status  - Status code returned by the CMD execution (0 indicates success).
    %   cmdout  - Output or error message returned by the CMD execution.
    
    % Validate the input
    if ~ischar(command) && ~isstring(command)
        error('Input command must be a string or character array.');
    end
    
    % Execute the command using the system function
    [status, cmdout] = system(command);
    
    % Display the results
    if status == 0
        fprintf('Command executed successfully.\n');
    else
        fprintf('Command failed with status %d.\n', status);
    end
    
    % Print the command output or error
    disp(cmdout);
end


