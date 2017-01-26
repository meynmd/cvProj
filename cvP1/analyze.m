function bbCorners = analyze(path)
    InitCorners = [190 52 341 264];
    
    % get the list of frames to analyze
    cd(path);
    conts = ls('*.jpg');
    files = split(conts);
    files = sort(files);
    
    numFiles = size(files, 1);
    dists = zeros(numFiles, 2);
    lastIdx = numFiles - 2;
    
    bbCorners = zeros(numFiles, 4);
    bbCorners(1,:) = InitCorners;
    
    % compute average distance between each pair    
    for i = 2:lastIdx
        img1 = loadImgGray(char(files(i)));
        img2 = loadImgGray(char(files(i + 1)));
        d = findDistance(img1, img2);
        bbCorners(i,1) = InitCorners(1) + d(1);
        bbCorners(i,2) = InitCorners(2) + d(2);
        bbCorners(i,3) = InitCorners(3) + d(1);
        bbCorners(i,4) = InitCorners(4) + d(2);
    end

end

% find the average distance between features in 2 images
function [dist] = findDistance(img1, img2)

    [p1, p2] = getMatchingPoints(img1, img2);

    loc1 = p1.Location;
    loc2 = p2.Location;
    dX = 0;
    dY = 0;
    
    if size(loc1, 1) ~= size(loc2, 1)
        error('images do not have same number of features');
    end
        
    numPoints = size(loc1, 1);
    for i = 1:numPoints
        dX = dX + loc2(i, 1) - loc1(i, 1);
        dY = dY + loc2(i, 2) - loc1(i, 2);
    end
        
    dist = [(dX / numPoints) (dY / numPoints)];
end

% find the matching points between img1, img2
function [points1, points2] = getMatchingPoints(img1, img2)
    [f1, v1] = getFeatures(img1);
    [f2, v2] = getFeatures(img2);
    
    pairs = matchFeatures(f1, f2);
    points1 = v1(pairs(:, 1), :);
    points2 = v2(pairs(:, 2), :);
    
    %points1 = points1.selectStrongest(10);
    %points2 = points2.selectStrongest(10);

end

function img = loadImgGray(path)
    img = imread(path);
    img = rgb2gray(img);
end

function [feat, vis] = getFeatures(img)    
    sf = detectSURFFeatures(img, 'MetricThreshold', 2000.0);
    
    [feat, vis] = extractFeatures(img, sf);
end


