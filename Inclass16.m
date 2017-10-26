% Inclass16

%The folder in this repository contains code implementing a Tracking
%algorithm to match cells (or anything else) between successive frames. 
% It is an implemenation of the algorithm described in this paper: 
%
% Sbalzarini IF, Koumoutsakos P (2005) Feature point tracking and trajectory analysis 
% for video imaging in cell biology. J Struct Biol 151:182?195.
%
%The main function for the code is called MatchFrames.m and it takes three
%arguments: 
% 1. A cell array of data called peaks. Each entry of peaks is data for a
% different time point. Each row in this data should be a different object
% (i.e. a cell) and the columns should be x-coordinate, y-coordinate,
% object area, tracking index, fluorescence intensities (could be multiple
% columns). The tracking index can be initialized to -1 in every row. It will
% be filled in by MatchFrames so that its value gives the row where the
% data on the same cell can be found in the next frame. 
%2. a frame number (frame). The function will fill in the 4th column of the
% array in peaks{frame-1} with the row number of the corresponding cell in
% peaks{frame} as described above.
%3. A single parameter for the matching (L). In the current implementation of the algorithm, 
% the meaning of this parameter is that objects further than L pixels apart will never be matched. 

% Continue working with the nfkb movie you worked with in hw4. 

% Part 1. Use the first 2 frames of the movie. Segment them any way you
% like and fill the peaks cell array as described above so that each of the two cells 
% has 6 column matrix with x,y,area,-1,chan1 intensity, chan 2 intensity

chan = 1;
t1 = 1;
t2 = 2;
zplane1 = 1;

reader1 = bfGetReader('nfkb_movie1.tif');

index_f1 = reader1.getIndex(zplane1-1, chan-1, t1-1)+1;
index_f2 = reader1.getIndex(zplane1-1, chan-1, t2-1)+1;

frame1 = bfGetPlane(reader1, index_f1);
frame2 = bfGetPlane(reader1, index_f2);

imshow(frame1, [100 2000]);
imshow(frame2, [100 2000]);

imshowpair(imadjust(frame1), imadjust(frame2));

% frame 1 segmenting
frame1_mask = frame1 > 622;
frame2_mask = frame2 > 622;

frame1_mask_p = imopen(frame1_mask, strel('disk', 7));
frame2_mask_p = imopen(frame2_mask, strel('disk', 7));

imshowpair(frame1_mask_p, frame2_mask_p);

stats_f1 = regionprops(frame1_mask_p, 'Area');
hist([stats_f1.Area]);

stats_f2 = regionprops(frame2_mask_p, 'Area');
hist([stats_f2.Area]);

min_area = 50;

frame1_mask_filter = bwareaopen(frame1_mask_p, min_area);
imshow(frame1_mask_filter);

frame2_mask_filter = bwareaopen(frame2_mask_p, min_area);
imshow(frame2_mask_filter);

imshowpair(frame1_mask_filter, frame2_mask_filter);

stats_t1 = regionprops(frame1_mask_filter, frame1, 'Centroid', 'Area', 'MeanIntensity');
stats_t2 = regionprops(frame2_mask_filter, frame2, 'Centroid', 'Area', 'MeanIntensity');


% chan2

index_f1_c2 = reader1.getIndex(zplane1-1, 2-1, t1-1)+1;
index_f2_c2 = reader1.getIndex(zplane1-1, 2-1, t2-1)+1;

frame1_c2 = bfGetPlane(reader1, index_f1);
frame2_c2 = bfGetPlane(reader1, index_f2);

frame1_mask_c2 = frame1_c2 > 622;
frame2_mask_c2 = frame2_c2 > 622;

frame1_mask_p_c2 = imopen(frame1_mask_c2, strel('disk', 7));
frame2_mask_p_c2 = imopen(frame2_mask_c2, strel('disk', 7));

imshowpair(frame1_mask_p_c2, frame2_mask_p_c2);

stats_f1_c2 = regionprops(frame1_mask_p_c2, 'Area');
hist([stats_f1_c2.Area]);

stats_f2_c2 = regionprops(frame2_mask_p_c2, 'Area');
hist([stats_f2_c2.Area]);

min_area = 50;

frame1_mask_filter_c2 = bwareaopen(frame1_mask_p_c2, min_area);
imshow(frame1_mask_filter_c2);

frame2_mask_filter_c2 = bwareaopen(frame2_mask_p_c2, 300);
imshow(frame2_mask_filter_c2);

imshowpair(frame1_mask_filter_c2, frame2_mask_filter_c2);

stats_t1_c2 = regionprops(frame1_mask_filter_c2, frame1_c2, 'Centroid', 'Area', 'MeanIntensity');
stats_t2_c2 = regionprops(frame2_mask_filter_c2, frame2_c2, 'Centroid', 'Area', 'MeanIntensity');

% data
xy1 = cat(1, stats_t1.Centroid);
a1 = cat(1, stats_t1.Area);
mi1 = cat(1, stats_t1.MeanIntensity);
mi1_c2 = cat(1, stats_t1_c2.MeanIntensity);
tmp = -1*ones(size(a1));
peaks{1} = [xy1, a1, tmp, mi1, mi1_c2];



xy2 = cat(1, stats_t2.Centroid);
a2 = cat(1, stats_t2.Area);
mi2 = cat(1, stats_t2.MeanIntensity);
mi2_c2 = cat(1, stats_t2_c2.MeanIntensity);
tmp = -1*ones(size(a2));
peaks{2} = [xy2, a2, tmp, mi2, mi2_c2];
% returns an error because mean intensity for channel 2 has different
% length


% Part 2. Run match frames on this peaks array. ensure that it has filled
% the entries in peaks as described above. 

addpath('TrackingCode/');

peaks_matched = MatchFrames(peaks, 3, 0.3);


% snippet
peaks{1} = [rand(10,3), -1*ones(10,1)];
peaks{2} = [rand(10,3), -1*ones(10,1)];
peaksnew = MatchFrames(peaks,2,0.3);


% Part 3. Display the image from the second frame. For each cell that was
% matched, plot its position in frame 2 with a blue square, its position in
% frame 1 with a red star, and connect these two with a green line. 

