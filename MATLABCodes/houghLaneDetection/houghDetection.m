function houghDetection (iter)

leftLanes = zeros(iter, 2);
rightLanes = zeros(iter, 2);
for z = 1:iter
    % Import the source image and convert to grayscale
    if z<10
        filePath = strcat('../../../Assets/RoadMarkingDataset/roadmark_000', num2str(z), '.jpg');
    elseif z<100
        filePath = strcat('../../../Assets/RoadMarkingDataset/roadmark_00', num2str(z), '.jpg');
    else
        filePath = strcat('../../../Assets/RoadMarkingDataset/roadmark_0', num2str(z), '.jpg');
    end
    source = imread(filePath);
    I = rgb2gray(source);

%     % if imported correctly, display image
%     colormap(gray(256));
%     image(I);

    % Initialize global variables for threshold settings
    [sourceHeight, sourceWidth] = size(I);
    scanLineCount = 5;
    scanLineLength = ceil(sourceWidth/10);
    scanLineBeginHeight = ceil(sourceHeight/4);
    thresholdMajorWeight = 0.75;
    thresholdMinorWeight = 0.25;
    rowIncrement = 1/12*sourceHeight;
    leftThreshValue = zeros(scanLineCount,1);
    rightThreshValue = zeros(scanLineCount,1);

    % Calculate array of left and right threshold intensity values
    for i=1:scanLineCount
        scanRow = sourceHeight - (rowIncrement*(i-1)) - scanLineBeginHeight;

        leftScanColumnMid = ceil((7/24*sourceWidth) + (rowIncrement*(i-1)*sourceWidth/2/sourceHeight));
        leftThreshValue(i) = max(I(scanRow, leftScanColumnMid-(scanLineLength/2) : leftScanColumnMid+(scanLineLength/2)));

        rightScanColumnMid = floor((17/24*sourceWidth) - (rowIncrement*(i-1)*sourceWidth/2/sourceHeight));
        rightThreshValue(i) = max(I(scanRow, rightScanColumnMid-(scanLineLength/2) : rightScanColumnMid+(scanLineLength/2)));
    end

    % Calculate left and right lane threshold values
    leftLaneIntensity = mean(leftThreshValue);
    rightLaneIntensity = mean(rightThreshValue);

    leftThreshold = thresholdMajorWeight*leftLaneIntensity + thresholdMinorWeight*rightLaneIntensity;
    rightThreshold = thresholdMajorWeight*rightLaneIntensity + thresholdMinorWeight*leftLaneIntensity;

    % Initializing global variables for lane extraction
    scanLineCount = ceil(5/12*sourceHeight);
    scanLineLength = ceil(sourceWidth/10);
    leftLane = zeros(scanLineCount,2);
    rightLane = zeros(scanLineCount,2);
    
    % Identify points on the left and right lanes based on the calculated
    % threshold
    for i=1:scanLineCount
        scanRow = (3/4*sourceHeight) - (i-1);
        for j=0:scanLineLength
            leftScanColumn = ceil((1/3*sourceWidth) + ((i-1)*sourceWidth/2/sourceHeight)) - j;
            if I(scanRow, leftScanColumn) > leftThreshold
                break;
            end
        end
        leftLane(i,:) = [leftScanColumn scanRow];

        for j=0:scanLineLength
            rightScanColumn = floor((2/3*sourceWidth) - ((i-1)*sourceWidth/2/sourceHeight)) + j;
            if I(scanRow, rightScanColumn) > rightThreshold
                break;
            end
        end
        rightLane(i,:) = [rightScanColumn scanRow];
    end
    
    imshow(source);
%     line(leftLane(:,1),leftLane(:,2));
%     line(rightLane(:,1),rightLane(:,2));
    
    % Populate the left and right hough matrices
    [leftPoints, ~] = size(leftLane);
    leftHoughArray = zeros(800,90);
    for i=1:leftPoints
        arr = houghTransform(leftLane(i,1), leftLane(i,2));
        leftHoughArray = leftHoughArray + arr;
    end
    
    [rightPoints, ~] = size(rightLane);
    rightHoughArray = zeros(800,90);
    for i=1:rightPoints
        arr = houghTransform(sourceWidth-rightLane(i,1), rightLane(i,2));
        rightHoughArray = rightHoughArray + arr;
    end
   
    % Identify the maximum occuring rho and delta values for left and right
    % lanes
    [colMax, rowIndex] = max(leftHoughArray);
    leftMax = max(colMax);
    k=1;
    for i=1:length(colMax)
        if colMax(i) == leftMax;
            leftRho(k) = rowIndex(i);
            leftTheta(k) = i;
            k=k+1;
        end
    end
    
    [colMax, rowIndex] = max(rightHoughArray);
    rightMax = max(colMax);
    k=1;
    for i=1:length(colMax)
        if colMax(i) == rightMax;
            rightRho(k) = rowIndex(i);
            rightTheta(k) = i;
            k=k+1;
        end
    end
    
    % Display the left and right lanes
    for i=1:length(leftRho)
        leftLanes(z,:) = reverseHoughTransform(leftRho(i),leftTheta(i), sourceWidth, sourceHeight, leftLanes);
        line(leftLanes(:,1), leftLanes(:,2));
        pause(0.25);
    end
    for i=1:length(rightRho)
        rightLanes(z,:) = reverseHoughTransform(rightRho(i),rightTheta(i), sourceWidth, sourceHeight, rightLanes);
        line(sourceWidth-rightLanes(:,1), rightLanes(:,2));
        pause(0.25);
    end
    
end

end