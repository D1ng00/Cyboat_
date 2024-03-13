% Project Capture
% Bruno Guerreiro (bj.guerreiro@fct.unl.pt)

% Summary: simulate simple dynamic system model of a boat

boat_init;

% main time loop for simulation
for k = 1:P.Nsim
    for iD = 1:P.nD
                
        % get state vector
        eta{iD} = x{iD}(1:3,k);
        nu{iD} = x{iD}(4:6,k);
        
        % get reference
        t = P.dTi*(k-1);
        [eta_d,nu_d] = get_boat_ref(t,Param);
%         eta_d = eta_ref{iD}(:,k);
%         nu_d = nu_ref{iD}(:,k);

        % mellinger controller
        [ctrl{iD}(:,k),e_x] = boat_ctrl(eta{iD},nu{iD},Param,eta_d,nu_d,xie{iD}(:,k),k*Param.dTi);
        
        % integrate errors
        %xie{iD}(:,k+1) = xie{iD}(:,k) + Param.dTi*e_x;
        
        % nonlinear drone model (continuous time)
        [dot_eta,dot_nu] = boat_full_dyn(eta{iD},nu{iD},ctrl{iD}(:,k),Param);
        
        % discretization 
        etap = eta{iD} + Param.dTi*dot_eta;
        nup = nu{iD} + Param.dTi*dot_nu;
        x{iD}(:,k+1) = [etap;nup];

        if any(abs(x{iD}(:,k+1))>1e6) || any(isnan(x{iD}(:,k+1)))
            break;
        end
    
    end

    if any(abs(x{iD}(:,k+1))>1e6) || any(isnan(x{iD}(:,k+1)))
        warning("State is diverging!");
        break;
    end
end

% trim vectors to same length
clear eta nu;
for iD = 1:P.nD
    ctrl{iD}(:,1:k) = ctrl{iD}(:,1:k);
    x{iD} = x{iD}(:,1:k);
    eta{iD} = x{iD}(1:3,:);
    nu{iD} = x{iD}(4:6,:);
end

boat_show_data;
