%% Entwickelt nach Matlab Beispiel für feature Detection,
% funktioniert nicht so gut für test images
function differenceEstimationPBRT(perspectiveImg,undistortedImg)
    
    
    % Finde Features in den Bildern
    perspectivePoints = detectSURFFeatures(perspectiveImg);
    undistortedPoints = detectSURFFeatures(undistortedImg);
    
    % extrahiere Features
    [perspectiveFeature,perspectiveVpts] = extractFeatures(perspectiveImg,perspectivePoints);
    [undistortedFeature,~] = extractFeatures(undistortedImg,undistortedPoints);
    
    % Finde gemeinsame Featueres
    matchedIndexPerspective = matchFeatures(perspectiveFeature, undistortedFeature);
    
    matchedPointsPerspective1 = perspectiveVpts(matchedIndexPerspective(:,1));
    matchedPointsPerspective2 = perspectiveVpts(matchedIndexPerspective(:,2));
    
    
    % Zeige Bewegung gemeinsamer Features
    figure(1);
    showMatchedFeatures(perspectiveImg,undistortedImg,matchedPointsPerspective1,matchedPointsPerspective2);
    legend('Matched Points perspective','Matched Points undistorted');
    title('Vergleich von Perspektivischem und Entzerrtem Bild');
    
    
    
    

end