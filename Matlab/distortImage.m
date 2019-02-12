%% Funktion zur Verzerrung eines Bildes
% Stehts ausgegangen von quadratischen Pixeln des Bildsensors
%
% Inputs: 
% Required:
% img - Bild mit Dimension X*Y*Farbkanäle
% polyCoefficients - Koeffizienten für Abhängigkeit von R
%   Bsp: 
%   polynomialCoefficients = [k0 k1 k2 k3]
%   dann gilt
%   Xd = Xu*(k0+k1*R+k2*R^2+k3*R^3)
%   mit R = X.^2+Y.^2
%
% Parameter:
% center 
%   Bildmittelpunkt in normalisierten Koordinaten: x,y in (-1:...:1) , Default: [0 0]
% distortionMode 'distort' oder 'undistort'
%   Erlaubt die Umkehrung der Verzerrung durch Interpolation, Default:
%   'distort' 
%   
% Output:
%   distortedImg
%     Verzerrtes Bild in gleicher Auflösung des unverzerrten Bildes
%   roi
%     Region of Interest, indem eine Entzerrung mit den gegebenen
%     Koeffizienten möglich ist.
%
function [imgOut,roi] = distortImage(imgIn,polyCoefficientsIn,varargin)
    %% Handle Inputs
    p = inputParser;
    
    %% Inputverifizierung
    checkImg = @(x) isnumeric(x) && ismember(ndims(x),[2 3]);
    checkCenter = @(x) isnumeric(x) && numel(x) == 2;
    checkPolyCoefficients = @(x) isnumeric(x);
    checkMode = @(x) ismember(x,{'distort','undistort'});
    
    %% Default Parameterwerte
    defaultCenter = [0 0];
    defaultMode = 'distort';
     
    %% Parser Initialisierung
    addRequired(p,'img',checkImg);
    addRequired(p,'polyCoefficients',checkPolyCoefficients);
    addParameter(p,'center',defaultCenter,checkCenter);
    addParameter(p,'distortionMode',defaultMode,checkMode);
    
    %% Parsing der Inputs
    parse(p,imgIn,polyCoefficientsIn,varargin{:});
    
    %% Auslesen der Inputs
    img = p.Results.img;
    center = p.Results.center;
    polyCoefficients = p.Results.polyCoefficients;
    mode = p.Results.distortionMode;
    
    %% Bestimmen von Rechengrößen
    Lx = size(img,2); % Länge in x Richtung
    Ly = size(img,1); % Länge in y Richtung
    pixelCount = Lx*Ly; % Gesamt Pixelzahl pro Farbkanal
    colorCount = size(img,3); % Anzahl der Farbkanäle
    
    center_scale = min(Lx,Ly)/2; % Center-Normierung nach Lensfun (center->shortside = 1)
    cx = center_scale*center(1); % X-Offset des Bildmittelpunktes in Px
    cy = center_scale*center(2); % Y-Offset des Bildmittelpunktes in Px
    
    %% Skalierung von X und Y auf normalisierte Koordinaten
    % Pixel Angabe -> Radius in -1:1
    scale = 1/sqrt(((Lx-1)/2)^2+((Ly-1)/2)^2);
    
    %% Bestimmung der normierten X und Y-Koordinaten mit Center-Offset
    
    xRange = scale*((-(Lx-1)/2:(Lx-1)/2)-cx);
    yRange = scale*((-(Ly-1)/2:(Ly-1)/2)-cy);
    [X,Y] = meshgrid(yRange,xRange);
    
    % Transponierung für Interpolant
    X=(X)';
    Y=(Y)';
    % Renormalisierung bei verschobenem Mittelpunkt 
    % (längste center-corner-distanz = 1, größter Radius liegt immer auf einer Bildecke)
    renorm = 1/max(sqrt(X(:).^2+Y(:).^2));
    X = renorm*X;
    Y = renorm*Y;
    
    
    %% Bestimmung der verzerrten X und Y-Koordinaten
    [distortedX,distortedY] = distortXY(X,Y,polyCoefficients);
    
    %%
    imgOut = zeros(size(img));
    
    %% Bestimmung der Region of Interest für Entzerrung
    
    roi = ones(size(img,1),size(img,2));
    %% Berechnung der X,Y Position nach Entzerrung
    for channel = 1:colorCount 
        if strcmp(mode,'distort')
                img_vector = reshape(img(:,:,channel),pixelCount,1);
                P = cat(3,distortedX,distortedY);
                %%
                P = reshape(P,pixelCount,2);
                interpolant = scatteredInterpolant(P,img_vector,'linear','none');
                imgOut(:,:,channel) = interpolant(X,Y);
        elseif strcmp(mode,'undistort')
                imgOut(:,:,channel) = interpn(X,Y,img(:,:,channel),distortedX,distortedY,'linear',NaN);
        end
        roi = roi & ~isnan(imgOut(:,:,channel));
    end
        
    
    
    %% Berechne das Verzerrungspolynom und verzerrte XY Coordinaten
    function [distortedX,distortedY] = distortXY(X,Y,polyCoefficients)
        %%
        R = sqrt(X.^2+Y.^2);
        R_factor = zeros(size(R));
        for index = 1:numel(polyCoefficients)
            exponent = index-1;
            R_factor = R_factor+polyCoefficients(index)*R.^(exponent);
        end
        distortedX = X.*R_factor;
        distortedY = Y.*R_factor;
        
    end
end