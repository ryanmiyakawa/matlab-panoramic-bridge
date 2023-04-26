% Runs mask model


% runMaskModel(p, '2D-dense-contacts-working', 'FDTD')

function domain = runMaskModel(p, simName, method)

   % Load Simulation
    p.loadSim(simName);
    
    
    % Modify variables:
    p.saveSim([simName, '-temp']);
    
    % Run simulation
    p.runSim(method);
    
    % getDomain:
    domain = p.getDomainInfo();
    





