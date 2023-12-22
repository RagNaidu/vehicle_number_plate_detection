clc; clear all; close all;

% Read the image
I = imread("C:\Users\saira\OneDrive\Desktop\RAG\5TH SEMESTER\SIP\ENDSEM\VEHICLE_NUMBER_PLATE_DETECTION\car8.jpeg");
figure(1);
imshow(I);
title('Input Image')

% Convert the RGB image to grayscale
Igray = rgb2gray(I);
[rows, cols] = size(Igray);
figure(2);
imshow(Igray);
title('GrayScale Image')

%% Dilate Image to remove noise
Idilate = Igray;
for i = 1:rows
    for j = 2:cols-1
        temp = max(Igray(i, j-1), Igray(i, j));
        Idilate(i, j) = max(temp, Igray(i, j+1));
    end
end
I = Idilate;

%% Display Dilated Image
figure(3);
imshow(Idilate);
title('Dilated Image');

%% Erode Image
Ierode = Idilate;
for i = 1:rows
    for j = 2:cols-1
        temp = min(Idilate(i, j-1), Idilate(i, j));
        Ierode(i, j) = min(temp, Idilate(i, j+1));
    end
end
I = Ierode;

% Display Eroded Image
figure(4);
imshow(Ierode);
title('Eroded Image');


%% Initialization of Some variables.
difference = 0;
sum = 0;
total_sum = 0;
difference = uint32(difference);

%% Processing edges in Horizontal Directions.
max_horz = 0;
maximum = 0;

for i = 2:cols
    sum = 0;
    for j = 2:rows
        if(I(j, i) > I(j-1, i))
            difference = uint32(I(j, i) - I(j-1, i));
        else
            difference = uint32(I(j-1, i) - I(j, i));
        end
        if(difference > 20)
            sum = sum + difference;
        end
    end
    horz1(i) = sum;

    % Finding Peak Value in Horizontal Histogram.
    if(sum > maximum)
        max_horz = i;
        maximum = sum;
    end

    total_sum = total_sum + sum;
end

average = total_sum / cols;
figure(5);
% Plot the Histogram for analysis
subplot(3,1,1);
plot(horz1);
title('Horizontal Edge Processing Histogram');
xlabel('Column Number ->');
ylabel('Difference ->');

%% Smoothening of the Horizontal Histogram by applying Moving average window.
sum = 0;
horz = horz1;

for i = 21:(cols-21)
    sum = 0;
    for j = (i-20):(i+20)
        sum = sum + horz1(j);
    end
    horz(i) = sum / 41;
end
subplot(3,1,2);
plot(horz);
title('Histogram after applying Moving average window');
xlabel('Column Number ->');
ylabel('Difference ->');

%% Filter out Horizontal Histogram Values by applying Dynamic Threshold
disp('Filtering out Horizontal Histogram.');

for i = 1:cols
    if horz(i) < average
        horz(i) = 0;
        for j = 1:rows
            I(j, i) = 0;
        end
    end
end

subplot(3,1,3);
plot(horz);
title('Histogram after Filtering');
xlabel('Column Number ->');
ylabel('Difference ->');

%% Processing edges in Vertical Directions.
difference = 0;
total_sum = 0;
difference = uint32(difference);

disp('Processing Edges Vertically...');

maximum = 0;
max_vert = 0;

for i = 2:rows
    sum = 0;
    for j = 2:cols
        if I(i, j) > I(i, j-1)
            difference = uint32(I(i, j) - I(i, j-1));
        end
        if I(i, j) <= I(i, j-1)
            difference = uint32(I(i, j-1) - I(i, j));
        end
        if difference > 20
            sum = sum + difference;
        end
    end
    vert1(i) = sum;

    % Finding Peak Value in Vertical Histogram.
    if sum > maximum
        max_vert = i;
        maximum = sum;
    end

    total_sum = total_sum + sum;
end

average = total_sum / rows;

figure(6)
subplot(3,1,1);
plot(vert1);
title('Vertical Edge Processing Histogram');
xlabel('Row Number ->');
ylabel('Difference ->');

%% Smoothening of the Vertical Histogram by applying Moving average window.

disp('Passing Vertical Histogram through Moving average window...');

sum = 0;
vert = vert1;

for i = 21:(rows-21)
    sum = 0;
    for j = (i-20):(i+20)
        sum = sum + vert1(j);
    end
    vert(i) = sum / 41;
end

subplot(3,1,2);
plot(vert);
title('Histogram after applying Moving average window');
xlabel('Row Number ->');
ylabel('Difference ->');

%% Filter out Vertical Histogram Values by applying Dynamic Threshold

disp('Filter out Vertical Histogram...');

for i = 1:rows
    if vert(i) < average
        vert(i) = 0;
        for j = 1:cols
            I(i, j) = 0;
        end
    end
end

subplot(3,1,3);
plot(vert);
title('Histogram after Filtering');
xlabel('Row Number ->');
ylabel('Difference ->');
figure(7);
imshow(I);

%% Find Probable candidates for Number Plate

% Finding columns with edges
j = 1;
for i = 2:(cols-2)
    if horz(i) ~= 0 && horz(i-1) == 0 && horz(i+1) == 0
        column(j) = i;
        column(j+1) = i;
        j = j + 2;
    elseif (horz(i) ~= 0 && horz(i-1) == 0) || (horz(i) ~= 0 && horz(i+1) == 0)
        column(j) = i;
        j = j + 1;
    end
end

% Finding rows with edges
j = 1;
for i = 2:(rows-2)
    if vert(i) ~= 0 && vert(i-1) == 0 && vert(i+1) == 0
        row(j) = i;
        row(j+1) = i;
        j = j + 2;
    elseif (vert(i) ~= 0 && vert(i-1) == 0) || (vert(i) ~= 0 && vert(i+1) == 0)
        row(j) = i;
        j = j + 1;
    end
end

[temp, column_size] = size(column);
if mod(column_size, 2)
    column(column_size+1) = cols;
end

[temp, row_size] = size(row);
if mod(row_size, 2)
    row(row_size+1) = rows;
end

%% Region of Interest-[ROI] Extraction

% Check each probable candidate
for i = 1:2:row_size
    for j = 1:2:column_size
        % If it is not the most probable region, remove it from the image
        if ~((max_horz >= column(j) && max_horz <= column(j+1)) && (max_vert >= row(i) && max_vert <= row(i+1)))
            % This loop is only for displaying proper output to the user
            for m = row(i):row(i+1)
                for n = column(j):column(j+1)
                    I(m, n) = 0;
                end
            end
        end
    end
end

figure(8);
imshow(I);



