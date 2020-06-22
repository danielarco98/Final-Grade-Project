
sca;
close all;
clear all;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
topPriorityLevel = MaxPriority(window);
Priority(1);
Screen('Preference', 'SkipSyncTests', 2);
Screen('Preference','VisualDebugLevel', 0);
KbName('UnifyKeyNames');


% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);


% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;


% Open an empty screen window while working
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Set the text size 
Screen('TextSize', window, 150);



%----------------------------------------------------------------------
%                Choose image files and randomise order 
%----------------------------------------------------------------------


im_foldername= 'ExperimentIm';
param_foldername= '';

Files = dir(im_foldername);
ImageFiles = Files(3:end,:); %First two are the parent directories


numTrials= size(ImageFiles, 1); % Total number of trials
indices= 1:numTrials;
randorders = indices(randperm(length(indices))); %randomise the order of trials

%load the condition matrix

params_mat= load( char('totalcondition_matrix.mat'));
condition_mat= params_mat.cond_mat;
condition_mat= condition_mat(randorders, :);

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
escapekey = KbName('ESCAPE');
leftkey = KbName('LeftArrow');
rightkey = KbName('RightArrow');
downkey = KbName('DownArrow');
upkey= KbName('UpArrow');
spacekey= KbName('space');

%----------------------------------------------------------------------
%                       Other Parameters
%----------------------------------------------------------------------
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;
% Here we set the lenght of our symmetry line
symmlinedim = 520;

% Set the line width for our fixation cross and symmetry line
lineWidthPix = 4;

% Degrees (not Radians) are used in these commands.
angles = 0:45:135;

nominalFrameRate = Screen('NominalFrameRate', window);
counterSecs = [sort(repmat(1:3, 1, nominalFrameRate), 'descend') 0];
counterSecs= counterSecs(1:end-1);


% We set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
% for the symmetry axis and fixation cross

fixationcrossXCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
fixationcrossYCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
fixationCoords = [fixationcrossXCoords; fixationcrossYCoords];


% Now we set the coordinates for the different symmetry lines
xCoords = [-symmlinedim symmlinedim -symmlinedim symmlinedim 0 0 -symmlinedim symmlinedim ];
yCoords = [0 0 symmlinedim -symmlinedim -symmlinedim symmlinedim -symmlinedim symmlinedim  ];         
    
%Store coordinates of the symmetry line for all orientations
allorientations = [xCoords; yCoords]; 

%----------------------------------------------------------------------
%                     Make a response matrix
%----------------------------------------------------------------------

% This is a six column matrix the first will record the global symmetry score,
% the second the local symmetry score, the third the score they respond,
% the fourth the real orientation, the fifth the responded orientation,
% and the final column the time they took to make there response.

respMat = nan(numTrials, 6);


%---------------------------------------------------------------------
%                       START EXPERIMENT
%---------------------------------------------------------------------

for n = 1:numTrials
    
    Screen('Flip', window);
    %Load the stimulus image
    imfile = strcat(im_foldername,'\', ImageFiles(randorders(n)).name);
    im = imread(imfile);
    %Wait to any key pressed to start the stimulus presentation
    %escape abort the experiment
    keyIsDown =0;
     while keyIsDown == 0
     [keyIsDown,secs, keyCode] = KbCheck;
     if keyCode(escapekey) 
        sca;
        Screen('CloseAll');
        break;      
     end
    end
    
    % Count-down timer that last 3s
    for i = 1:length(counterSecs)
        % Convert our current number to display into a string
        numberString = num2str(counterSecs(i));
        
        % Draw our number to the screen
        DrawFormattedText(window, numberString, 'center', 'center', white);
        
        % Flip to the screen
        Screen('Flip', window);
    end
    

    % Draw the fixation cross in white, set it to the center of our screen and
    % set good quality antialiasing
    Screen('DrawLines', window, fixationCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    
    % Flip to the screen
    Screen('Flip', window);
    
    
    % Make the image into a texture
    imageTexture = Screen('MakeTexture', window, im);
    % Draw the image to the screen in its correct orientation.
    Screen('DrawTexture', window, imageTexture, [], [], 0);
    
    WaitSecs(1);
    
    finaltime=0;
    % Check the keyboard. If space is pressed a symmetry axis is detected 
    %If escape no axis of symmetry detected so skip to next image
    keyIsDown = 0;
    s0=GetSecs; %Get timestamp
    
    % Flip to the screen and record the timestamp
    initime= Screen('Flip', window);
    while keyIsDown == 0
     si= GetSecs;
     [keyIsDown,secs, keyCode] = KbCheck;
     if keyCode(spacekey) %Space means that they perceived symmetry
        orienting= 1;
        scoring=1; 
        index= 1;
        score=1;
     elseif keyCode(escapekey) %Escape means no symmetry detected, so no scoring
        orienting= 0;
        scoring=0; 
        index= -1;
        score=0;
     elseif si-s0 >= 60 %Wait 60s as maximum for stimulus presentation
         finaltime= Screen('Flip',window);
     end
     
    end
    
    if finaltime ==0
        finaltime= Screen('Flip',window);
    end
    
    totaltime= finaltime- initime;
    WaitSecs(0.5);
    
    isdrawing=1;
    
    
    %------------------------------------------------------------------
    %               Axis of Symmetry Classification screen
    %------------------------------------------------------------------
    while orienting ==1

        if isdrawing == 1
             
             
             %Select the coordinates corresponding to the symmetry axis
             %selected by user
             selectedorientation= allorientations(:, index * 2 -1: index*2);

             
             % Draw the fixation cross in white, set it to the center of our screen and
             % set good quality antialiasing
             Screen('DrawLines', window, selectedorientation,...
                 lineWidthPix, white, [xCenter yCenter], 2);
             
             % Flip to the screen
             Screen('Flip', window);
        
            WaitSecs(0.25);
            isdrawing=0;
        end
        
        %Allow the subjects change the orientation
        [keyIsDown,secs, keyCode] = KbCheck;
         if keyCode(spacekey) %Space for accepting the symmetry axis selected
            orienting= 0;
            WaitSecs(1);
         elseif keyCode(leftkey) %change the symmetry axis 45º clockwise
            index= index+1;
            if index == 5
                index=1;
            end
            isdrawing=1;
            
         elseif keyCode(rightkey) %change the symmetry axis 45º anti-clockwise
             index= index-1;
             if index == 0
                 index = 4;
             end
             isdrawing=1;
            
         end
        
    end
    
    WaitSecs(0.5);
    
    %-----------------------------------------------------------------
    %                   Symmetry Scoring screen
    %-----------------------------------------------------------------

    Screen('FillRect',window, grey, windowRect);
    DrawFormattedText(window, num2str(score), 'center', 'center', white);
    Screen('Flip', window);
    
    while scoring == 1
        [keyIsDown,secs, keyCode] = KbCheck;
         if keyCode(spacekey) 
            scoring= 0;
         elseif keyCode(upkey)
            score= score+1;
            if score == 6
                score=1;
            end
            Screen('FillRect',window, grey, windowRect);
            DrawFormattedText(window, num2str(score), 'center', 'center', white);
            Screen('Flip', window);
            WaitSecs(0.25);
         elseif keyCode(downkey)
             if score == 0
                 score = 5;
             end
            score= score-1;
            Screen('FillRect',window, grey, windowRect);
            DrawFormattedText(window, num2str(score), 'center', 'center', white);
            Screen('Flip', window);
            WaitSecs(0.25);
         end   
    end
    %Store the different variables and scores on the response matrix
    respMat(n, 1:2) = condition_mat(n, 1:2);
    respMat(n, 3) = score;
    respMat(n, 4) = condition_mat(n, 3);
    if index ==-1
    respMat(n, 5) = index;
    else
        respMat(n, 5) = angles(index);
    end
    respMat(n, 6) = totaltime;
    
    WaitSecs(0.5);
end

% Clear the screen
sca;
Screen('CloseAll');

%------------------------------------------------------------------
%                     Save the response matrix
%------------------------------------------------------------------
prompt = {'Enter file name:'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'TestResponse'};
answ = inputdlg(prompt,dlg_title,num_lines,defaultans);
save(strcat('Results\', answ{1},'.mat'), 'respMat');

