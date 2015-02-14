% arguments need to be at the end, after source and callbackdata which are
% fixed args: http://stackoverflow.com/questions/9078790/pushbutton-to-change-variable
% the two arguments 'source' and 'callbackdata' are required to be
% specified otherwise it doesn't work. taken from http://in.mathworks.com/help/matlab/ref/uicontrol.html

function exciteKaro(source,callbackdata, s)
  % since asynchronous multithreaded work on MATLAB is not possible, we
  % will simply use serial communication to arduino and write the functions
  % on the arduino. http://arduino.stackexchange.com/questions/140/how-can-i-communicate-from-arduino-to-matlab
  
  fprintf(s, 'w')          % single character to communicate white LED should be turned on*
  
  %{
  fclose(s);
  delete(s);
  clear s;
  %}
end