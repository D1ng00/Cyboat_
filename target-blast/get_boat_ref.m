function [eta_d,nu_d] = get_boat_ref(t,Param)
    nt = length(t);
    if Param.ref_mode == 1 % line reference
        Vnorm = 2;
        nu_d = [Vnorm;0;0]*ones(1,nt);
        eta_d = Param.eta0 + nu_d.*t;
        
    else % circle reference
        phase = 0;
        Rad = 6;      % radius of circle
        omn = 2*pi/20;  % rotation frequency
        eta_d = [ Rad*cos(omn*t+phase);Rad*sin(omn*t+phase);omn*t+phase];
        nu_d = [-Rad*omn*sin(omn*t+phase);Rad*omn*cos(omn*t+phase);omn*ones(1,nt)];
    end

end
