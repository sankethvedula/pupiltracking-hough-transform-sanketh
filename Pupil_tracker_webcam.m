%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 																 
%    Aim : Pupil detection and diameter plot							 
%    Authors : Dhruv Joshi											 
%    Acknowledgements : Sujeath Pareddy, Sandeep Konam
%    Organization : Srujana - Center for Innovation, LVEPI						 	 
%																 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Approach :: Extracting frames -> Thresholding the frame at hand  -> cropping out excess -> Circle Detection(Pupil Approximation) -> Radius measurement -> Plotting the graph
% to be able to see the two feeds (greyscale and thresholded) simultaneously, uncomment the subplot part.

close all;
clear all;
clc;

pointsArray = [];                         % creating an appendable empty array
currentData = [];

%% open the arduino object. Setup all the arduino stuff (including fixed brightness for IR LEDs and white LED
% http://playground.arduino.cc/Interfacing/Matlab
% http://www.mathworks.in/help/supportpkg/arduinoio/examples/getting-started-with-matlab-support-package-for-arduino-hardware.html?prodcode=ML
%{
a = arduino();
ir_brightness = 0.8;    % this needs to be in the range (0,1). This value is optimized for our specific case
ir = 9;

% writing to the LED via PWM...
writePWMDutyCycle(a, ir, ir_brightness);
%}

s = serial('COM10');      % serial communication object, change com port as needed
fopen(s)                  % open the serial port for comm

%% declare the video object
vid = videoinput('winvideo', 1,'YUY2_320x240');          % Video Parameters

% next we print out the properties of the webcam. 
src = getselectedsource(vid);
get(src)

set(vid,'ReturnedColorSpace','grayscale');      % acquire in greyscale
triggerconfig(vid, 'manual');					% manual trigger, increase speed

start(vid);                                     % start acquiring from imaqwindow
gcf = figure;                                   % figure

closeflag = 1;

set(gcf,'CloseRequestFcn',{@my_closefcn, vid, closeflag})			% this is incomplete
                                 
subplot(1,2,1); 

% to pass arguments to callback functions http://stackoverflow.com/questions/16693464/matlab-callback-function-only-sees-one-parameter-passed-to-it
btn = uicontrol('Style', 'pushbutton', 'String', 'EXCITE', 'Position', [20 20 50 20], 'Callback', {@exciteKaro, s});
hold on;										% image will persist

%% the following variables will be used to measure the time
t1 = clock;                                     % initialize time
t = 0;                                                   

% Ask the user for the name of the file to write to..
rawFileName = inputdlg('Enter file name');
fileName0 = strcat(rawFileName(1), '.txt');    % The
fileName = fileName0{:};                    % This needs to be done to convert cell to string, http://stackoverflow.com/questions/13258508/how-to-convert-a-cell-to-string-in-matlab

% we write the header to the file and keep..
% the at is required to open the file in text mode so that carriage return
% and newline are recognized. http://www.mathworks.com/matlabcentral/answers/101268-why-doesn-t-the-carriage-return-or-new-line-character-in-fprintf-work-properly
fid = fopen(fileName, 'at');
fprintf(fid, '%s\t%s\n\r', 'Time(ms)', 'Radius (arb. units)');
fclose(fid);

while(closeflag)                                % infinite loop
    %% first we acquire the feed and crop out unrequired parts to speed it all up
    acquired_snapshot = getsnapshot(vid);       % acquire single image from feed
    cropped_snapshot = imcrop(acquired_snapshot,[110 30 130 110]);   % crop it out so that you can see just the center ref: http://www.mathworks.in/help/images/ref/imcrop.html
    subplot(1,2,1), imshow(cropped_snapshot);  % normal camera (greyscale)
    
    %% Then we threshold it to some value of threshold to be able to get the pupil out
    thresholded_image = im2bw(cropped_snapshot,0.30);   % threshold karo... this value has been obtained after playing around
    % subplot(1,2,2),         imshow(thresholded_image);  % display the image
        
    %% next we extract circles from this baby...and plot them if they are found
    [centers, radii] = imfindcircles(thresholded_image,[10 20], 'ObjectPolarity','dark','Sensitivity',0.85); 
    
    if ~isempty(centers)                        % plot only if circle is detected.. ~ is logical not. simple error handling for viscircles
      viscircles(centers, radii,'EdgeColor','b', 'LineWidth', 1);
      % disp(radii(1))                          % just seeing radii range
      % all the plotting...
      y = radii(1);                             % radii(1) is the first returned radius, converted to y-variable
      t2 = clock;                               % finding out the time elapsed
      drawnow
      subplot(1,2,2);
      hold on;
      
      currentData = [etime(t2,t1)*1000, y];          % the newest entries to the data array
      pointsArray = [pointsArray; currentData];      % appending the array with the new entries
      % using dlmwrite to append to text file
      % http://matlab.izmiran.ru/help/techdoc/ref/dlmwrite.html
      dlmwrite(fileName, currentData, 'delimiter', '\t', '-append', 'newline', 'pc');
      
       if t == 0
         plot(pointsArray(t+1),pointsArray(t+1,2), 'linewidth',1.0),xlabel('time in ms'),ylabel('Pupil radius'); %pllotting the points by taking the value from the array
       end
       if t ~= 0 
           plot(pointsArray(t:t+1),pointsArray(t:t+1,2), 'linewidth',1.0),xlabel('time in ms'),ylabel('Pupil radius');%should work on this part this should give lines
           % plot(pointsArray(t),pointsArray(t+1,2), 'linewidth',1.0);
       end
       t = t + 1;                               % t just counts the iterations
    end
   
    pause(0.001);                               % much less than 30 fps. wihtout this it doesn't seem to work
end% Preview

fclose(s)
delete(s)
clear s
