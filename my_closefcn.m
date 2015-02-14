% function to close the damn figure...
function my_closefcn(source,callbackdata, vid, closeflag)
  closeflag = ~closeflag;
  hold off
  delete(gcf);
  delete(vid);
  fclose(s)
  delete(s)
  clear s
  close all;
end