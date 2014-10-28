close all;
clear all;
vid = VideoReader('video001.mp4');
nFrames = vid.NumberOfFrames;
vidHeight = vid.Height;
vidWidth = vid.Width;
%disp(vidHeight);
disp(vidWidth);
%disp(nFrames);
get(vid);
duration = vid.Duration;
disp(duration);
for i = 1:nFrames
    currFrame = read(vid,i);
    size_1 = size(currFrame);
    %currFrame_resized = currFrame(100:end-100,100:end-100);
    img_gray = rgb2gray(currFrame);
    %disp(size_1);
    img_gray_cropped = img_gray(:,(320:960));
    %img_gray_cropped = img_gray
    %img_gray_1 = img_gray[size(img_gray,1
    %imwrite(img_gray,'sample','jpg');
    %b = imread('sample.jpg');
    %img_gray_hist = adapthisteq(img_gray);
    %img_bw = im2bw(img_gray_hist);
    %img_bw1 = bwmorph(img_bw,'close');
    %imshow(img_gray_cropped);
    %pause(10);
    [accum,circen,cirrad] = CircularHough_Grd(img_gray,[25,50]);
    imshow(img_gray);
    hold on;
    plot(circen(:,1),circen(:,2),'r+');
        for k =1: size(circen,1)
            if ((circen(k,1)<=960)&&(circen(k,1)>=320))
                DrawCircle(circen(k,1),circen(k,2),cirrad(k),32,'b-');
                disp(circen);
                disp(cirrad);
            end
        end
    
    hold off;
    pause(.0001);
end

    
    
