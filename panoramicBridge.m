% Make sure that Panoramic api server is running (search "api" in start)
%
% Panoramic Bridge v0.0.6 (2023.04.23) Ryan Miyakawa 
%
% The PanoramicBridge class is a MATLAB interface to the Panoramic simulation software's API. The class provides methods to load, save, and simulate Panoramic simulations, as well as set and get simulation variables and data.
% 
% Properties
%     jarPath (string): The file path to the Panoramic MATLAB API jar file.
%     apiPath (string): The file path to the Panoramic API directory.
%     simulationPath (string): The file path to the directory containing Panoramic simulation files.
%     simResultHandle (handle): The handle to the Panoramic simulation output data.
%     simResultIndices (array): The indices of the output data series in the simResultHandle.
%     simResultHeaders (cell array): The headers of the output data series in the simResultHandle.
%     imgResultHandle (handle): The handle to the Panoramic simulated image data.
%     nOutX (integer): The number of pixels in the output image along the X axis.
%     nOutY (integer): The number of pixels in the output image along the Y axis.
% 
% Methods
%     Constructor
%         PanoramicBridge - Creates an instance of the PanoramicBridge class.
%           Usage: pb = panoramicBridge('jarPath', <path_to_jar_file>, 'apiPath', <path_to_api_directory>, 'simulationPath', <path_to_simulation_directory>)
%           All arguments are optional. If not specified, default values will be used.
%           Example usage: pb = panoramicBridge(...
%               'jarPath', 'C:\Program Files\Panoramic\v700\api\MATLAB_6_5.jar', ...
%               'apiPath', 'C:\Program Files\Panoramic\v700\api', ...
%               'simulationPath', 'C:\Users\rhmiyakawa\Documents\Panoramic Sims')
%     Public Methods
%         destroyOutputs - Destroys all outputs created by the simulation.
%         destroyDataSeries - Destroys all data series created by the simulation.
%         loadSim(simName) - Loads a Panoramic simulation from a file.
%         saveSim(simName) - Saves the current Panoramic simulation to a file.
%         loadTOBOutput(simName) - Loads a TOB output file generated by a Panoramic simulation.
%         setVariable(varName, value) - Sets the value of a simulation variable.
%         getVariable(varName) - Gets the value of a simulation variable.
%         getProperty(varName) - Gets the value of a property of the Panoramic simulation.
%         setZernikeTable(zrnAr) - Sets the Zernike table for the Panoramic simulation.
%         setIllumination(aoi, NA, sigma) - Sets the illumination for the Panoramic simulation.
%         simulateImage(Nx, Ny) - Simulates an image for the current Panoramic simulation.
%         getImageData(nmpp) - Gets the simulated image data for the current Panoramic simulation.
%         runSim(method) - Runs the current Panoramic simulation using the specified method.
%         getHeuristicDomainInfo - Gets the domain info from stored variables.
%         getDomainInfo - Gets the domain info for the current Panoramic simulation.
%         getDataSeries(dataName, coherenceGroup) - Gets a data series from the output of the current Panoramic simulation.
%     Static Methods
%         init - Initializes the PanoramicBridge class by connecting to Panoramic and adding the necessary paths to the MATLAB environment.
%         loadMaterials - Loads materials from the materials.json file and adds them to the EM suite in Panoramic.
%         pupilSpaceToAngles(aoi, NA, sigma) - Converts pupil space parameters to angles used in Panoramic simulations.
%

classdef panoramicBridge < handle
    properties (Constant)
       
        
    end
    
    properties
        simResultHandle
        simResultIndices
        simResultHeaders = {}
        imgResultHandle
        
        jarPath = 'C:\Program Files\Panoramic\v700\api\MATLAB_6_5.jar'
        apiPath = 'C:\Program Files\Panoramic\v700\api'
        simulationPath = 'C:\Users\rhmiyakawa\Documents\Panoramic Sims'
        
        nOutX = 50
        nOutY = 50
    end
    
    methods
        
        function obj = panoramicBridge(varargin)
            % Constructor for panoramicBridge class.
            % Usage: pb = panoramicBridge('jarPath', <path_to_jar_file>, 'apiPath', <path_to_api_directory>, 'simulationPath', <path_to_simulation_directory>)
            % All arguments are optional. If not specified, default values will be used.
            % Example usage: pb = panoramicBridge('jarPath', 'C:\Program Files\Panoramic\v700\api\MATLAB_6_5.jar', 'apiPath', 'C:\Program Files\Panoramic\v700\api', 'simulationPath', 'C:\Users\rhmiyakawa\Documents\Panoramic Sims')
            
            % Set default values for properties
            jarPath = obj.jarPath;
            apiPath = obj.apiPath;
            simulationPath = obj.simulationPath;
            
            % Parse optional arguments
            if nargin > 0
                for i = 1:2:nargin
                    switch varargin{i}
                        case 'jarPath'
                            jarPath = varargin{i+1};
                        case 'apiPath'
                            apiPath = varargin{i+1};
                        case 'simulationPath'
                            simulationPath = varargin{i+1};
                        otherwise
                            warning(['Unknown parameter: ' varargin{i}])
                    end
                end
            end
            
            % Set properties
            obj.jarPath = jarPath;
            obj.apiPath = apiPath;
            obj.simulationPath = simulationPath;
        end
                 
        function destroyOutputs(~)
           destroyAllOutputs(); 
        end
        
        function destroyDataSeries(~)
           destroyAllDataSeries(); 
        end
        function lSuccess = loadSim(~, simName)
            disp('Loading Simulation')
            try
                loadSetup(fullfile(panoramicBridge.simulationPath, [simName, '.sim']))
            catch
                fprintf('Failed to load simulation "%s".  Make sure this path exists \n', simName);
                lSuccess = false;
                return
            end
            fprintf('Successfully loaded simulation "%s".\n', simName)
            lSuccess = true;
        end
       
        
        function saveSim(~, simName)
            disp('Saving Simulation')
            try
                saveSetup([panoramicBridge.simulationPath '\' simName])
            catch
                fprintf('Failed to save simulation "%s".\n', simName);
                return
            end
            fprintf('Successfully saved simulation "%s".\n', simName)
        end
        
        function lSuccess = loadTOBOutput(this, simName)
            disp('Loading TOB output')
            try
                hOutputHandle = loadOutput(fullfile(panoramicBridge.simulationPath, [simName, '.tob']));
                this.simResultHandle = hOutputHandle;
                
            catch
                fprintf('Failed to load output "%s".  Make sure this path exists \n', simName);
                lSuccess = false;
                return
            end
            fprintf('Successfully loaded output "%s".\n', simName)
            lSuccess = true;
        end
        
        function setVariable(~, varName, value)
            disp('Setting Variable')
            try
                setVariableValues(varName, value)
            catch
                fprintf('Failed to set variable "%s" to value %f.\n', varName, value);
                return
            end
            fprintf('Successfully set variable "%s" to value %f.\n', varName, value)
        end
        
        function value = getVariable(~, varName)
            disp('Getting Variable')
            try
                value = getVariableValues(varName);
            catch
                fprintf('Failed to get variable "%s".\n', varName);
                return
            end
            fprintf('Successfully got variable "%s".\n', varName)
        end
        
        function value = getProperty(~, varName)
            disp('Getting Variable')
            try
                value = getProperty(varName);
            catch
                fprintf('Failed to get property "%s.\n', varName);
                return
            end
            fprintf('Successfully get property "%s.\n', varName)
        end
        
        function setZernikeTable(this, zrnAr)
            
            %{
                [Version]
                13.2.2.11

                [Parameters]
                Name = Example
                Type = ZRN
                NAType = Fit
                Normalization = Maximum

                [Data]
                Z5 = -0.05
                Z8 = 0.08
                Z9 = -0.09
                Z12 = 0.12
                Z16 = 0.16
                Z17 = -0.17
                Z25 = 0.25
            %}

            % Get path to zrn file:
            zrnPath = fullfile(panoramicBridge.simulationPath, 'zrnAr.zrn');
            fid = fopen(zrnPath, 'w');

            % Write the header as defined above
            fprintf(fid, '[Version]\n');
            fprintf(fid, '13.2.2.11\n\n');
            fprintf(fid, '[Parameters]\n');
            fprintf(    fid, 'Name = Example\n');
            fprintf(fid, 'Type = ZRN\n');
            fprintf(fid, 'NAType = Fit\n');
            fprintf(fid, 'Normalization = Maximum\n\n');
            fprintf(fid, '[Data]\n');

            % Now write each element of zrnAr where the index is of the form Z[index] = zrnAr[index]:
            for ii = 1:length(zrnAr)
                fprintf(fid, 'Z%d = %f\n', ii, zrnAr(ii));
            end

            % Close the file:
            fclose(fid);

            % load data into Panoramic:
            zrnH = loadDataSeries(zrnPath);
            setZernikeTable(zrnH);
            
            % build zern array str:
            zrnstr = [];
            for k = 1:length(zrnAr)
                zrnstr = sprintf('%s %0.3f', zrnstr, zrnAr(k));
            end
            
            fprintf('Set zernike table component to: [%s]\n',zrnstr);

        end
        
        
        function setIllumination(this, aoi, NA, sigma)
            % Convert NA and sigma to angles:
            [theta, phi] = panoramicBridge.pupilSpaceToAngles(aoi, NA, sigma);
            
            % Now set these variables:
            this.setVariable('aoi', theta);
            this.setVariable('azi', phi);
        end
        
        
        function simulateImage(this, Nx, Ny)
            
            if nargin == 1
               Nx = 50;
               Ny = 50;
            end
            
            if strcmp(Ny, 'nmpp')
               nmpp = Nx;
               % get domain info:
               stDom = this.getHeuristicDomainInfo();
               
               
               Nx = round(stDom.xSize);
               Ny = round(stDom.ySize);
            end
            
            % Set mask output as image input
            setObject(this.simResultHandle);
            
            
            this.nOutX = Ny;
            this.nOutY = Nx;
            
            this.setVariable('nOutX', this.nOutX);
            this.setVariable('nOutY', this.nOutY);
            
            this.imgResultHandle = simulateImage(1);
        end
        
        function [data, dX, dY] = getImageData(this, nmpp)
            if nargin == 1
                nmpp = 1;
            end
            
            data = {};
            dataHandles = getDataSeriesHandlesForOutput(this.imgResultHandle);
            
            % get domain info:
            try
                dom = getDataSeriesDomainInfo(dataHandles);
                pX = dom(7);
                pY = dom(8);

                stDom = this.getHeuristicDomainInfo();

                               
                raw = reshape(getDataSeriesData(dataHandles), this.nOutX, this.nOutY)';
                
                
                nY = round(stDom.ySize/nmpp);
                nX =  round(stDom.xSize/nmpp);
                dY = linspace(0, stDom.ySize, nY);
                dX = linspace(0, stDom.xSize, nX);
                
                
                data{1} = imresize(raw, [round(stDom.ySize/nmpp), round(stDom.xSize/nmpp)]);
                
                % Remove data series now that we have the data:
                destroyDataSeries(dataHandles);
                
            
            
%                 for ii = 1:length(dataHandles)
%                     data{end + 1} = reshape(getDataSeriesData(dataHandles(ii)), this.nOutX, this.nOutY); %#ok<AGROW>
%                 end
            catch
                fprintf('Failed to get image data.\n');
                return
            end
            fprintf('Successfully got image data.\n');
        end
        
        function runSim(this, method)
            disp('Running Simulation')
            
            % Clear any data:
            clearList();
            
            try
                t0 = tic;
                switch method
                    case 'RCWA'
                        this.simResultHandle = simulateMaskUsingRCWA(1);
                    case 'FDTD'
                        this.simResultHandle = simulateMaskUsingTEMPESTpr2(1);
                    otherwise
                        fprintf('Invalid simulation method "%s".\n', method);
                        return
                end
                toc(t0);
                
                % Grab output handles and names
                soh = getDataSeriesHandlesForOutput(this.simResultHandle);
                for ii = 1:length(soh)
                    outStr(:,ii) = cell(callJavaFunction('panoramictech.v700.OpenAPI.CAPIClient','getDataSeriesText',soh(ii)));
                end
                this.simResultHeaders = outStr;
                this.simResultIndices = soh;
            catch
                fprintf('Failed to run simulation.\n');
                return
            end
            fprintf('Successfully ran simulation.\n')
        end
        
        % Gets domain info from stored variables:
        function d = getHeuristicDomainInfo(this)
            xSize = this.getVariable('xpitch');
            ySize = this.getVariable('ypitch');
            
            d.xSize = xSize;
            d.ySize = ySize;
        end
        
        function d = getDomainInfo(this)
            domain = getDataSeriesDomainInfo(this.simResultIndices(1));
            
            nx = domain(1);
            ny = domain(2);
            xSize = domain(7) - domain(4);
            ySize = domain(8) - domain(5);
            z = domain(6);
            
            d.nx = nx;
            d.ny = ny;
            d.xSize = xSize;
            d.ySize = ySize;
            d.z = z;
            
        end
        
        function data = getDataSeries(this, dataName, coherenceGroup)
            if (nargin == 2)
                coherenceGroup = 0;
            end
            disp('Getting Data')
            
            
            data = {};
            datIdx = [];
            for ii = 1:size(this.simResultHeaders, 2)
                headerCell1 = this.simResultHeaders(1,ii);
                headerCell2 = this.simResultHeaders(2,ii);
                if contains(headerCell1{1},dataName) && strcmp(headerCell2{1}, sprintf('cgrp=%d.0', coherenceGroup))
                    datIdx(end+1) = this.simResultIndices(ii); %#ok<AGROW>
                end
            end
            if isempty(datIdx)
                fprintf('Failed to get data "%s".\n', dataName);
                return
            end
            
            
            try
                for ii = 1:length(datIdx)
                    data{end + 1} = getDataSeriesData(datIdx(ii)); %#ok<AGROW>
                end
            catch
                fprintf('Failed to get data "%s".\n', dataName);
                return
            end
            fprintf('Successfully got data "%s".\n', dataName)
        end
    end
    
    methods(Static)
        
        function init()
            disp('Initializing Panoramic Bridge')
            mpm addpath
            
            javaaddpath(panoramicBridge.jarPath);
            addpath(panoramicBridge.apiPath);
            
            if connectPanoramic()~=0
                disp('connection failed!');
                return;
            end
            
            disp('complete!');
        end
        
        % Loads materials a specified in materials.json
        function materials = loadMaterials()
            % get directory of current mfile:
            mfileDir = fileparts(which(mfilename));
            
            % Load materials json and store into a static variable:
            materials = jsondecode(fileread(fullfile(mfileDir, 'materials.json')));
            
            materialNames = fieldnames(materials);
            
            for k = 1:length(materialNames)
                material = materials.(materialNames{k});
                
                % add material to EM suite:
                try
                    addMaterial(materialNames{k}, material.n, material.k, 1, 0, material.colorName, 0.9);
                catch
                    fprintf('Failed to add material "%s" to EM suite.\n', materialNames{k});
                    continue
                end
                
                
                fprintf('Added material "%s" to EM suite.\n', materialNames{k});
            end
        end
        
        
        function [theta, phi] = pupilSpaceToAngles( aoi, NA, sigma)
            
            if (length(NA) == 1)
                NA = [NA NA];
            end
            
            NAx = NA(1);
            NAy = NA(2);
            Sx = sigma(1);
            Sy = sigma(2);
            
            sinTheta    = sqrt(NAy^2 * Sy^2 + (sind(aoi) +  NAx * Sx)^2);
            theta       = asind(sinTheta);
            phi         = atan2d(Sy * NAy, sind(aoi) + NAx * Sx);
            
        end
        
        
        
    end
end