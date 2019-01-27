%% Funktion zur Verzerrung eines Bildes
% Inputs: 
% img - Bild mit Dimension X*Y*Farbkanäle
% polyCoefficients - Koeffizienten für Abhängigkeit von R
%   Bsp: 
%   polynomialCoefficients = [k0 k1 k2 k3]
%   Xd = Xu*(k0+k1*R+k2*R^2+k3*R^3);
% 
function distortedImg = distortImage(img,varargin)
    %% Handle Inputs
    p = inputParser;
    % Bild vorhanden und im korrekten Format
    checkImg = @(x) isnumeric(x) && ismember(ndims(img),[2 3]);
    addRequired(p,'img',checkImg);
    checkCenter = @(x) isnumeric(x) && numel(x) == 2;
    
    defaultCenter = [(size(img,1)+1)/2 (size(img,2)+1)/2];
    addRequired(p,'polyCoefficients',@(x) isnumeric(x));
    addParameter(p,'distFun',@(X,Y,coeff) defaultDistortion(X,Y,coeff),@(x) isa(x,'function_handle'));
    addParameter(p,'centerXY',defaultCenter,checkCenter);
    addParameter(p,'invertDistortion',false,@(x) islogical(x));
    
    parse(p,img,varargin{:});
    %%
    Lx = size(img,1); % Länge in x Richtung
    Ly = size(img,2); % Länge in y Richtung
    pixelCount = Lx*Ly;
    colorCount = size(img,3);
    %%
    centerXY = p.Results.centerXY;
    polyCoefficients = p.Results.polyCoefficients;
    distFun = p.Results.distFun;
    %%
    cx = centerXY(1);
    cy = centerXY(2);
    
    %%
    % Skalierung von X und Y auf [-1:1]
    [X,Y] = meshgrid(((1:Lx)-cx)/(Lx-1),((1:Ly)-cy)/(Ly-1));
%     [X,Y] = meshgrid(((1:Lx)-cx)/(max(Lx,Ly)-1),((1:Ly)-cy)/(max(Lx,Ly)-1));
%     [X,Y] = meshgrid(((1:Lx)-cx)*2/(min(Lx,Ly)-1),((1:Ly)-cy)*2/(min(Lx,Ly)-1));
    
    X=X';
    Y=Y';
    

    
    distortedImg = zeros(size(img));
    [distortedX,distortedY] = distFun(X,Y,polyCoefficients);
        
    % Berechnung der X,Y Position nach Entzerrung (muss bei
    % defaultDistortion nur einmal gemacht werden
    if p.Results.invertDistortion
       for channel = 1:colorCount
        distortedImg(:,:,channel) = interpn(X,Y,img(:,:,channel),distortedX,distortedY);
       end
    else
       for channel = 1:colorCount
        %%
        img_vector = reshape(img(:,:,channel),pixelCount,1);
        P = cat(3,distortedX,distortedY);
        P = reshape(P,pixelCount,2);
        interpolant = scatteredInterpolant(P,img_vector);
        %% Verzerrung durch Interpolation zwischen Punkten
        distortedImg(:,:,channel) = interpolant(X,Y);

       end
    end
        
    
    
    %% Berechne das Verzerrungspolynom
    function [distortedX,distortedY] = defaultDistortion(X,Y,polyCoefficients)
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