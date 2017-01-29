function bbCorners = trackObject(path)
    InitCorners = [190 52 341 264];
    
    % get the list of frames to analyze
    cd(path);
    gtBoxes = importdata('gt.txt', ',');
    conts = ls('*.jpg');
    files = split(conts);
    files = sort(files);
    numFiles = size(files, 1);
            
    bbCorners = zeros(numFiles, 4);
    bbCorners(1,:) = InitCorners;
    
    % compute distance between each pair
    lastIdx = numFiles - 2;
    for i = 2:lastIdx
        img1 = loadImgGray(char(files(i)));
        img2 = loadImgGray(char(files(i + 1)));
        d = findDistance(img1, img2);
        bbCorners(i,1) = bbCorners((i - 1),1) + d(1);
        bbCorners(i,2) = bbCorners((i - 1),2) + d(2);
        bbCorners(i,3) = bbCorners((i - 1),3) + d(1);
        bbCorners(i,4) = bbCorners((i - 1),4) + d(2);
        
        imshow(img2); hold on;
        rectangle('Position', bbCorners(i, :), 'EdgeColor', 'y', 'LineWidth', 2);
        rectangle('Position', gtBoxes(i, :), 'EdgeColor', 'b', 'LineWidth', 2);        
        drawnow; hold off;       
        
        if mod(i, 10) == 0
            cd('../results');
            outFilename = strcat('frame', string(i), '.png');
            saveas(gcf, char(outFilename));
            cd(char(strcat('../', path)));
        end
        
    end

end

% find the median distance between features in 2 images
function [dist] = findDistance(img1, img2)

    [p1, p2] = getMatchingPoints(img1, img2);

    loc1 = p1.Location;
    loc2 = p2.Location;
    dX = 0;
    dY = 0;
    
    if size(loc1, 1) ~= size(loc2, 1)
        error('images do not have same number of features');
    end
    
    d = size(loc1);
    numPoints = d(1);
    dists = zeros(numPoints, 3);

    for i = 1:numPoints
        dists(i, 1) = loc2(i, 1) - loc1(i, 1);
        dists(i, 2) = loc2(i, 2) - loc1(i, 2);
        x = dists(i, 1);
        y = dists(i, 2);
        dists(i, 3) = sqrt(x*x + y*y);
    end
    
    distsSorted = sortrows(dists, 3);
    idx = round(numPoints / 2);
    medDist = distsSorted(idx, :);
            
    dist = [medDist(1) medDist(2)];
    
end

% getMatchingPoints: find the matching points between img1, img2
function [points1, points2] = getMatchingPoints(img1, img2)
    [f1, v1] = getFeatures(img1);
    [f2, v2] = getFeatures(img2);
    
    pairs = matchFeatures(f1, f2);
    points1 = v1(pairs(:, 1), :);
    points2 = v2(pairs(:, 2), :);
end

function img = loadImgGray(path)
    img = imread(path);
    img = rgb2gray(img);
end

function [feat, vis] = getFeatures(img)    
    sf = detectSURFFeatures(img, 'MetricThreshold', 300.0);
    %sf = detectMSERFeatures(img);
    
    [feat, vis] = extractFeatures(img, sf);
end


