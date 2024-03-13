% Project Capture
% Bruno Guerreiro (bj.guerreiro@fct.unl.pt)
function [ctrl,e_x] = boat_ctrl(eta,nu,P,eta_d,nu_d,ie_x,t)

    % define translation errors
    %e_p = eta(1:2) - eta_d(1:2);
    %e_yaw = eta(3) - atan2(e_p(2),e_p(1));
    %e_v = nu(1:2) - nu_d(1:2);
    %e_dyaw = atan2(e_v(2),e_v(1));
    %ie_Va = ie_x(1);
    %ie_yaw = ie_x(2);

    % thrust control
    %Va_ref = norm(nu_d(1:2));
    %Va = norm(nu(1:2));
    %e_Va = Va - Va_ref;

    % surge velocity controller
    %n_p = -P.kp_n*e_Va - P.ki_n*ie_Va;

    % direction controller
    %delta = -P.kp_delta*e_yaw - P.ki_n*ie_yaw - P.kv_delta*e_dyaw;

%     ctrl = [sat(n_norm,1);sat(delta,P.delta_max)];
    if t<0.1
        ctrl = [0;-1];
    else
        ctrl = [1;-1];
    end
    e_x =0; %[e_Va;e_yaw];
    
%     if t > 0.001
%         fprintf('t = %f: T = %f; tau = [%f %f %f]; e_p = [%f %f %f]; e_v = [%f %f %f]; f_d = [%f %f %f]; e_R = [%f %f %f]; e_om = [%f %f %f].\n',...
%             t,T,tau(1),tau(2),tau(3),e_p(1),e_p(2),e_p(3),e_v(1),e_v(2),e_v(3),...
%             f_d(1),f_d(2),f_d(3),e_R(1),e_R(2),e_R(3),e_om(1),e_om(2),e_om(3));
%         test = 1;
%     end
    
end

