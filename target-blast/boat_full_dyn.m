function [deta,dnu] = boat_full_dyn(eta,nu,ctrl,P)
%DRONE_MODEL Summary of this function goes here
%   Detailed explanation goes here

    % get state and control variables
    n_norm = sat(ctrl(1),1);
    n_p = n_norm*P.n_p_max;
    delta = sat(-ctrl(2),P.delta_max);
    psi = eta(3);
    u = nu(1);
    v = nu(2);
    r = nu(3);
    
    % kinematics equation
    J = Euler2R([0;0;psi]);
    deta = J*nu;

    % define parametric components
    Crb = [ 0              ,  0     , P.m*(P.Xg*r+v)
            0              ,  0     , P.m*u
            P.m*(P.Xg*r+v) , -P.m*u , 0              ];
    Ca  = [  0               , 0       ,  P.Ydv*v+P.Ydr*r
             0               , 0       , -P.Xdu*u
            -P.Ydv*v-P.Ydr*r , P.Xdu*u ,  0          ];
    C = Ca + Crb;
    Dn = [ P.Xuu*abs(u) , 0                         , 0 
           0            , P.Yvv*abs(v)+P.Yvr*abs(r) , P.Yrv*abs(v)+P.Yrr*abs(r)
           0            , P.Nvv*abs(v)+P.Nvr*abs(r) , P.Nrv*abs(v)+P.Nrr*abs(r) ];
    D = P.Dconst + Dn;

    Va = norm(nu(1:2)); % assuming no current
%     Tp = P.Tnn*abs(n_p)*n_p + P.Tnv*abs(n_p)*Va;
    Tp = n_p/P.n_p_max*P.T_p_max;
    Fr = 0*P.Kdelta*Va^2*delta;
    tau = [ Tp*cos(delta) - Fr*sin(delta)
            Tp*sin(delta) + Fr*cos(delta)
            P.Lcg*(Tp*sin(delta) + Fr*cos(delta)) ];

    % dynamics
    dnu = P.M\(tau - 0*C*nu - D*nu);

    if any(abs(dnu)>1e3) || any(isnan(dnu)) || any(abs(deta)>1e3) || any(isnan(deta))
        disp("Boat dynamics diverging!");
    end
%     if any(abs(dnu)>1e10)
% 
% %     if t > 0.001
%         test = 1;
%     end
    
end

function u_sat = sat(u,u_max)

    if u > u_max
        u_sat = u_max;
    elseif u < -u_max
        u_sat = -u_max;
    else
        u_sat = u;
    end

end