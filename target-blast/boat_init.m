% Project Capture
% Bruno Guerreiro (bj.guerreiro@fct.unl.pt)

% inicializations

clear all;

% Model and simulation parameters
P.Tend = 14;
P.dTi = 0.01;
P.Nsim = round(P.Tend/P.dTi)+1;
P.nD = 1;         % number of boats
P.dh = 0.05;      % safety height difference between drones
P.Rad = 0.5;      % radius of circle
P.omn = 2*pi/20;  % rotation frequency
P.dphase = -pi/12;% ref circle angular difference between drones

P.ref_mode = 2; % reference: 1 - line reference; 2 - circle

posicoes = readtable('csv\1\posne1.csv');
servo = readtable('csv\1\SERVO.csv');
yaw = readtable('csv\1\GYRZ.csv');
velocityx= readtable('csv\1\SPEEDX.csv');
velocityY =readtable('csv\1\VELOCITY_DOWN.csv');
P.TIME = (table2array(servo(:,1))-table2array(servo(1,1)))*1e-3; % in seconds starting at zero
P.TIME = P.TIME';
P.SERVO = table2array(servo(:,4));
P.SERVO = P.SERVO';
P.THRUST = table2array(servo(:,5));
P.THRUST = P.THRUST';
P.POS = table2array(posicoes(:,[3,5])) - table2array(posicoes(1,[3,5]));  % starting at zero
P.p0 = P.POS(1,:)';
P.YAW = table2array(yaw(:,2));
P.VELX = table2array(velocityx(:,2));
P.VELX = P.VELX';
P.VELY = table2array(velocityY(:,3));

% Traxxas blast
% define model parameters
rho = 1000;   % Water density
m = 1.5;     % Mass
L = 0.603;    % Length overall
Lcg = 0.197;  % Longitudinal center of gravity
T = 0.083;    % Draft 
Lwl = 0.455;  % Length on the waterline
Bwl = 0.118;  % Beam on the waterline
Xg = 0;   
Iz = 0.9;     % made up! compute using solid works!
% hidrodynamic coefficients based on [Kli+16] https://doi.org/10.1109/JOE.2016.2571158
% everything need a thorough identification study!
Xdu = 0.1*(-m);
Ydv = 0.2*(-pi*rho*L*T^2);
Ydr = 2.1*(-1/2*pi*rho*T^2*((L-Lcg)^2 + Lcg^2));
Ndv = 1*(-1/2*pi*rho*T^2*((L-Lcg)^2 + Lcg^2));
Ndr = 0.7*(-1/2*pi*rho*T^2*( 4.75*Bwl/2*T^2 + 2/3*((L-Lcg)^2 + Lcg^2) ));
Ma = -[ Xdu , 0   , 0 
        0   , Ydv , Ydr
        0   , Ndv , Ndr    ];
Mrb = [ m , 0    , 0 
        0 , m    , m*Xg
        0 , m*Xg , Iz     ];
P.M = Mrb + Ma;

P.m = m;
P.Lcg = Lcg;
P.Xg = Xg;
P.Xdu = Xdu;
P.Ydv = Ydv;
P.Ydr = Ydr;
P.u_eq = 1;
P.v_eq = 0;
P.r_eq = 0;
P.Va_eq = sqrt(P.u_eq^2 + P.v_eq^2);
Xu = -1.1; %see table II of [Kli+16]; special care needed here as not based on model scale...
Yv = 0.8*(-40/2*pi*rho*T*abs(P.v_eq)*(1.1+0.0045*L/T-0.1*Bwl/T + 0.016*(Bwl/T)^2));
Yr = 0.8*(-pi*rho*T^2*L*P.Va_eq);
Nv = 0.8*(-pi*rho*T^2*L*P.Va_eq);
Nr = 0.2*(-pi*rho*T^2*L^2*P.Va_eq);
P.Xuu = 3; %see table II of [Kli+16]; special care needed here as not based on model scale...
Cd = 0.5;
P.Yvv = 1*(-rho*T*L*Cd);
P.Yvr = 1.5*(-1/2*rho*T*((L-Lcg)^2 + Lcg^2));
P.Yrv = P.Yvr;
P.Yrr = 1.5*(-1/3*rho*T*Cd*((L-Lcg)^3 + Lcg^3));
P.Nvv = P.Yvr;
P.Nvr = P.Yrr;
P.Nrv = P.Yrr;
P.Nrr = 1*(-1/4*rho*T*Cd*((L-Lcg)^4 + Lcg^4));
P.Dconst = -[   Xu , 0  , 0 
                0  , Yv , Yr
                0  , Nv , Nr    ];
P.n_p_max = 3620; % rad/s (7.2V * 4800Kv = 34560 rpm ~ 3620 rad/s)
P.T_p_max = 10; % 1.0 kgf
Kf = 0.5;
P.delta_max = 60*pi/180;
P.Kdelta = pi*Kf/(2*P.delta_max);

% % Gains for nonlinear controller TBD
P.kp_n = 1;
P.ki_n = 0;
P.kp_delta = 1;
P.ki_n = 0;
P.kv_delta = 0;

% Param.kp = diag([8,8,6]);
% Param.kv = diag([5,5,5]);
% Param.ki = diag([0,0,0]);
% Param.kR = diag([8,8,8]);
% Param.kom= diag([0.5,0.5,0.5]);

% initial conditions
P.eta_ref_static = [0.5;0.5;pi/3];

% initialize variables for all drones:
t = 0:P.dTi:P.Tend;
nt = length(t);
nx = 6;
nctrl = 2;
for iD = 1:P.nD

    % set initial conditions
    eta0{iD} = [0;0.2*((P.nD-1)/2-iD+1);0];
    nu0{iD} = [2;0;0];
    x{iD} = zeros(nx,P.Nsim+1);
    xie{iD} = zeros(nctrl,P.Nsim+1);
    ctrl{iD} = zeros(nctrl,P.Nsim);
    x{iD}(:,1) = [eta0{iD};nu0{iD}];

    if iD == 1 % Set main initial condition
        P.eta0 = eta0{iD};
        P.nu0 = nu0{iD};
    end
    
    [eta_ref{iD},nu_ref{iD}] = get_boat_ref(t,P);
    eta_ref_all{iD} = [eta_ref{iD};nu_ref{iD}];

end

Param = P;
