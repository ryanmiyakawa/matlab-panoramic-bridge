% Make sure that Panoramic api server is running (search "api" in start)

classdef maskStackGenerator < handle
    properties (Constant)
   

    end

    properties 
        currentZ = 0
       
    end

    methods
        function obj = maskStackGenerator()
            obj.currentZ = 0;
        end
        
        
        function z = getCurrentZ(this)
            z = this.currentZ;
        end

        function generateIMOMultilayer(this)

            % Generate substrate:
            this.addLayer('IMO_LTEM_Substrate', 20);

            % Generate 40 pairs of Si, MoSi2, Mo, MoSi2:
            N = 40;
            for i = 1:N
                this.addLayer('IMO_MoSi2', 1.05);
                this.addLayer('IMO_Mo', 2.05);
                this.addLayer('IMO_MoSi2', 1.66);
                this.addLayer('IMO_Si', 2.28);
            end
        end
        
        function generateIMOCap(this, type)
            switch type
                case 'PSM'
                    this.generateIMOPSMCap();
                case 'BA'
                    this.generateIMOBACap();
            end
                    
        end

        function generateIMOBACap(this)
            % Generate intermixing layer:
            this.addLayer('IMO_BA_intermix', 0.8);

            % Capping:
            this.addLayer('IMO_MLCap', 2.5);
        end

        function generateIMOPSMCap(this)
            % Capping:
            this.addLayer('IMO_PSM_MLCap', 2);
        end

        % Boxes are struct arrays of: [XBounds, YBounds]
        % Materials are struct array of: [material, thickness]
        % Entry mode should be either 'number' or 'string', which determines whether the bounds are entered as numbers or strings
        function generateAbsorberStack(this, boxes, stackName, entryMode)


            materials = [];
            switch stackName
                case 'BA'
                    materials = [...
                        struct(...
                            'material', 'IMO_BA_Abs_bulk',...
                            'thickness', 58 ...
                        ),...
                        struct(...
                            'material', 'IMO_BA_Abs_top',...
                            'thickness', 2 ...
                        )...
                    ];
                case 'PSM'
                    materials = [...
                        struct(...
                            'material', 'IMO_PSM_Abs_bot',...
                            'thickness', 29 ...
                        ),...
                        struct(...
                            'material', 'IMO_PSM_Abs_mid',...
                            'thickness', 8 ...
                        ),...
                        struct(...
                            'material', 'IMO_PSM_Abs_top',...
                            'thickness', 11 ...
                        )...
                    ];

            end

            if isempty(materials)
                error('Invalid stack name');
            end

            numBoxes = length(boxes);

            % get list of thicknesses, computed as the difference between the Zbounds:
            thicknesses = zeros(length(materials), 1);
            for i = 1:length(materials)
                thicknesses(i) = materials(i).thickness;
            end
            
            zBox = this.currentZ;
            for k = 1:length(materials)
                for m = 1:numBoxes
                    % add each box at this thickness:
                    if (strcmp(entryMode, 'number'))
                        this.addBox(materials(k).material, boxes(m).XBounds, boxes(m).YBounds, [zBox, zBox + thicknesses(k)]);
                    elseif (strcmp(entryMode, 'string'))
                        if  (~iscell(boxes(m).XBounds))
                            boundCell = {sprintf('%0.3f', boxes(m).XBounds(1)), sprintf('%0.3f', boxes(m).XBounds(2))};
                            boxes(m).XBounds = boundCell;
                        end
                        if  (~iscell(boxes(m).YBounds))
                            boundCell = {sprintf('%0.3f', boxes(m).YBounds(1)), sprintf('%0.3f', boxes(m).YBounds(2))};
                            boxes(m).YBounds = boundCell;
                        end
                        this.addBoxString(materials(k).material, boxes(m).XBounds, boxes(m).YBounds, [zBox, zBox + thicknesses(k)]);
                    else
                        error('Invalid entry mode');
                    end
                end
                zBox = zBox + thicknesses(k);
            end
        end

        % Adds a block with the given type, material, and bounds
        function addBox(this, material, XBounds, YBounds, ZBounds)
            addBlock('box', material, sprintf('%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f', XBounds(1), XBounds(2), YBounds(1), YBounds(2), ZBounds(1), ZBounds(2)));
        end
        
        % Adds an absorber box with the given material, XBounds, YBounds  are cell arrays of strings.  ZBounds are numbers  Useful for entering variables
        function addBoxString(this, material, XBounds, YBounds, ZBounds)
            addBlock('box', material, sprintf('%s,%s,%s,%s,%0.3f,%0.3f', XBounds{1}, XBounds{2}, YBounds{1}, YBounds{2}, ZBounds(1), ZBounds(2)));
        end

        function addLayer(this, material, thickness)
            addBlock('layer', material, sprintf('%0.3f,%0.3f', this.currentZ, this.currentZ + thickness));
            this.currentZ = this.currentZ + thickness;
        end
    


    end

end