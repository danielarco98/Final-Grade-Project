%Adapted from http://peterscarfe.com/ptbtutorials.html
sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
topPriorityLevel = MaxPriority(window);
Priority(1);
Screen('Preference', 'SkipSyncTests', 2);
Screen('Preference','VisualDebugLevel', 0);
KbName('UnifyKeyNames');

% Get the screen numbers
screens = Screen('Screens');

% Select the external screen if it is present, else revert to the native
% screen
screenNumber = max(screens);

% Define black
% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;


% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);
Screen('Flip', window);


escapekey = KbName('ESCAPE');
spacekey= KbName('space');

% Flip to the screen
keyIsDown = 0;
while keyIsDown == 0
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapekey) 
        sca;
        Screen('CloseAll');
        break;      
     end
end
WaitSecs(0.5);
im_foldername= 'Explanation';

%Load the image
imfile = strcat(im_foldername,'\', 'g0.bmp');
im= imread(imfile);
symmlinedim = 520;
%define coords of the symmetry line
xCoords = [-symmlinedim symmlinedim ];
yCoords = [0 0 ];         
symmline = [xCoords; yCoords]; 
% Set the line width and height for our symmetry line

lineWidthPix = 4;
% Make the image into a texture
imageTexture = Screen('MakeTexture', window, im);
    
% Draw the image to the screen in its correct orientation.
Screen('DrawTexture', window, imageTexture, [], [], 0);
Screen('Flip', window);
keyIsDown =0;

%show the image until any key is pressed if esc finish
while keyIsDown == 0
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapekey) 
        sca;
        Screen('CloseAll');
        break;      
     end
end


Screen('DrawLines', window, symmline, lineWidthPix, white, [xCenter yCenter], 2);
Screen('Flip', window);
WaitSecs(0.5); 

keyIsDown =0;

while keyIsDown == 0
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapekey) 
        sca;
        Screen('CloseAll');
        break;      
     end
end


WaitSecs(0.5);

imfile = strcat(im_foldername,'\', 'g90.bmp');
im= imread(imfile);
%define coords of the symmetry line
xCoords = [0 0];
yCoords = [-symmlinedim symmlinedim ];         
symmline = [xCoords; yCoords]; 

% Make the image into a texture
imageTexture = Screen('MakeTexture', window, im);
    
% Draw the image to the screen in its correct orientation.
Screen('DrawTexture', window, imageTexture, [], [], 0);
Screen('Flip', window);

keyIsDown =0;

while keyIsDown == 0
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapekey) 
        sca;
        Screen('CloseAll');
        break;      
     end
end

Screen('DrawLines', window, symmline, lineWidthPix, white, [xCenter yCenter], 2);
Screen('Flip', window);
WaitSecs(0.5);
keyIsDown =0;

while keyIsDown == 0
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapekey) 
        sca;
        Screen('CloseAll');
        break;      
     end
end
WaitSecs(0.5);

imfile = strcat(im_foldername,'\', 'g45.bmp');
im= imread(imfile);
%define coords of the symmetry line
xCoords = [-symmlinedim symmlinedim];
yCoords = [symmlinedim -symmlinedim ];         
symmline = [xCoords; yCoords]; 


% Make the image into a texture
imageTexture = Screen('MakeTexture', window, im);
    
% Draw the image to the screen in its correct orientation.
Screen('DrawTexture', window, imageTexture, [], [], 0);
Screen('Flip', window);


keyIsDown =0;

while keyIsDown == 0
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapekey) 
        sca;
        Screen('CloseAll');
        break;      
     end
end

Screen('DrawLines', window, symmline, lineWidthPix, white, [xCenter yCenter], 2);
Screen('Flip', window);
WaitSecs(0.5);

keyIsDown =0;

while keyIsDown == 0
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapekey) 
        sca;
        Screen('CloseAll');
        break;      
     end
end

WaitSecs(0.5);
imfile = strcat(im_foldername,'\', 'g135.bmp');
im= imread(imfile);
%define coords of the symmetry line
xCoords = [-symmlinedim symmlinedim];
yCoords = [-symmlinedim symmlinedim ];         
symmline = [xCoords; yCoords]; 

% Make the image into a texture
imageTexture = Screen('MakeTexture', window, im);
    
% Draw the image to the screen in its correct orientation.
Screen('DrawTexture', window, imageTexture, [], [], 0);
Screen('Flip', window);
keyIsDown =0;

while keyIsDown == 0
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapekey) 
        sca;
        Screen('CloseAll');
        break;      
     end
end

Screen('DrawLines', window, symmline, lineWidthPix, white, [xCenter yCenter], 2);
Screen('Flip', window);
WaitSecs(0.5);

keyIsDown =0;

while keyIsDown == 0
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapekey) 
        sca;
        Screen('CloseAll');
        break;       
     end
end
WaitSecs(0.5);

imfile = strcat(im_foldername,'\', 'g0.85_l0.5.bmp');
im= imread(imfile);

% Make the image into a texture
imageTexture = Screen('MakeTexture', window, im);
    
% Draw the image to the screen in its correct orientation.
Screen('DrawTexture', window, imageTexture, [], [], 0);
Screen('Flip', window);
keyIsDown =0;

while keyIsDown == 0
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapekey) 
        sca;
        Screen('CloseAll');
        break;      
     end
end

% Clear the screen
close all;
sca
