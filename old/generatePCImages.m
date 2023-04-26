% Computes images based on mask model.  Must run mask model before doing
% this


function img = generatePCImages(p, varargin)

    % Parse inputs
    parser = inputParser;
    addParameter(parser, 'dz0', 0);
    addParameter(parser, 'NZ', 0);
    addParameter(parser, 'dz', 100);
    addParameter(parser, 'flare', 0);
    addParameter(parser, 'vibx', 0);
    addParameter(parser, 'viby', 0);
    addParameter(parser, 'vibz', 0);

    
    parse(parser, varargin{:});

    % loop through parser.Results and assign to local variables
    fields = fieldnames(parser.Results);
    for i = 1:length(fields)
        p.setVariable(fields{i}, parser.Results.(fields{i}));
    end
    

    p.simulateImage();

    img = p.getDataSeries('3D', 0);

    


    
    





