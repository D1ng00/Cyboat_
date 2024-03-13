% Project Capture
% Bruno Guerreiro (bj.guerreiro@fct.unl.pt)
% 
% Summary: script that plots basic simulation results

imgs_folder = 'figures/';
saves_folder = 'saves/';
if ~exist('filename','var') || isempty(filename)
    filename = [datestr(now,30) '_simul_boat'];
end
do_print = 0; % set to 1 to plot each plot in a PDF file (for latex reports)
do_save_workspace = 0; % set to 1 to save workspace to *.mat file

% test if results are from script or simulink and prepare variables
% accordingly:
if exist('out','var') 
    nD = 1; % force number of drones to 1

    t = out.simout.time;
    data = permute(out.simout.signals.values,[1,3,2]);
    
    [n1,n2] = size(out.simout.signals.values);
    if n1 > n2 % diferent Matlab versions use the transpose of the data values
        data = data';
    end
    ref{1} = data((1:6),:);
    x{1} = data(6+(1:6),:);
    ctrl{1} = data(6+6+(1:2),:);
    xie{1} = data(6+6+2+(1:2),:);
    
    eta{1} = x{1}(1:3,:);
    
    eta_ref{1} = ref{1}(1:3,:);
    nu_ref{1} = ref{1}(4:6,:);

end

% show results plot
set(0,'defaultTextInterpreter','latex');
set(0,'defaultLegendInterpreter','latex');
sstblue         = [0,128,255]/255;
sstlightblue    = [48,208,216]/255;
sstlighterblue  = [50,220,240]/255;
sstlightestblue = [60,230,255]/255;
sstgreen        = [43,191,92]/255;
sstlightgreen   = [140,255,200]/255;
sstlightergreen = [160,255,225]/255;
sstgray         = [70,70,70]/255;
sstlightgray    = [200,200,200]/255;

dcolors = { sstgreen, sstblue, sstlightblue, sstlighterblue, sstlightestblue, sstlightgreen, sstlightergreen, sstlightgray };

sstgray = [70,70,70]/255;
nD = length(eta);
nt = length(t);
dt = mean(t(2:end)-t(1:end-1));

x_values = linspace(0, P.Tend, numel(ctrl{1}(1,:)));
x_values_truncado = x_values(1:length(posicoes.POSPN))*10;


figure(100);
for iD = 1:nD
    %hini{iD} = plot(eta{iD}(1,1),eta{iD}(2,1),'o','Color',dcolors{iD},'MarkerSize',2);
    if iD == 1, hold on; end
    href{iD} = plot(posicoes.POSPE,posicoes.POSPN,'--','Color',sstgray); %OBTIDAS EXPERIMENTALMENTE
    hp{iD} = plot(eta{iD}(1,:),eta{iD}(2,:),'-','Color',dcolors{iD});
    boat_plot(eta{iD}(:,1),[],dcolors{iD});
    last_p = eta{iD}(1:2,1);
    for k = 2:10:nt
        dp = norm(eta{iD}(1:2,k) - last_p);
        if dp > 1.5
            boat_plot(eta{iD}(:,k),[],dcolors{iD});
            last_p = eta{iD}(1:2,k);
        end
    end
    boat_plot(eta{iD}(:,end),[],dcolors{iD});
end
hold off;
grid on;
axis equal;
% axis([-1.2 1.2 -1.2 1.2 0 3]);
xlabel('x [m]');
ylabel('y [m]');
legend('experimental','simulated','start');
print2pdf([imgs_folder filename '_traj'],do_print);



%Delta e control

figure(106);
subplot(211);
plot(x_values,ctrl{1}(1,:)*100,'Color',dcolors{1}); 
hold on;
for iD = 2:nD
    plot(x_values,ctrl{iD}(1,:)*100,'Color',dcolors{iD});
end
hold off;
grid on;
ylabel('$$n_p(t)$$ [\%]');
title('Control variables');
subplot(212);
plot(x_values,ctrl{1}(2,:)*180/pi,'Color',dcolors{1});
hold on;
for iD = 2:nD
    plot(x_values,ctrl{iD}(2,:)*180/pi,'Color',dcolors{iD});
end
hold off;
grid on;
ylabel('$$\delta(t)$$ [deg]');
print2pdf([imgs_folder filename '_act'],do_print);


%Delta e control

figure(101);
subplot(211);
plot(x_values_truncado,posicoes.POSPN,'Color',sstgray);
hold on;
plot(x_values,x{1}(1,:),'Color',dcolors{1});
% hold on;
for iD = 2:nD
    plot(x_values_truncado,posicoes.POSPN,'Color',sstgray);
    plot(x_values,x{iD}(1,:),'Color',dcolors{iD});
end
hold off;
grid on;
ylabel('$$x(t)$$ [m]');
title('Vessel position simulated and experimental');
subplot(212);
plot(x_values_truncado,posicoes.POSPE,'Color',sstgray);
hold on;
plot(x_values,x{1}(2,:),'Color',dcolors{1});
% hold on;
for iD = 2:nD
    plot(x_values_truncado,posicoes.POSPE,'Color',sstgray);
    plot(x_values,x{iD}(2,:),'Color',dcolors{iD});
end
hold off;
grid on;
ylabel('$$y(t)$$ [m]');

% subplot(313);
% plot(x_values_truncado,P.YAW*180/pi,'Color',sstgray);
% hold on;
% plot(x_values,x{1}(3,:)*180/pi,'Color',dcolors{1});
% % hold on;
% for iD = 2:nD
%     plot(x_values,eta_ref{iD}(3,:)*180/pi,'Color',sstgray);
%     plot(x_values,x{iD}(3,:)*180/pi,'Color',dcolors{iD});
% end
% hold off;
% grid on;
% xlabel('$$t$$ [s]');
% ylabel('$$\psi(t)$$ [deg]');
print2pdf([imgs_folder filename '_eta'],do_print);

erro1= posicoes.POSPE - x{1}(1,:);
erro_medio1 = abs(mean(posicoes.POSPE) - mean(x{1}(1,:)));
% Mostra o erro médio no título do subplot
title(['Mean Error: ', num2str(erro_medio1)]);
% Plot do erro médio posicoes.POSPE e eta{iD}(1,:)
figure(105);
subplot(311);
plot(x_values_truncado, erro1, 'Color', 'r');
grid on;
xlabel('Time');
ylabel('Error');
title(['Mean Error POSX: ', num2str(erro_medio1)]);

erro2=posicoes.POSPN -x{1}(2,:);
erro_medio2 = abs(mean(posicoes.POSPN) - mean(x{1}(2,:)));
% Plot do erro médio
subplot(312);
plot(x_values_truncado, erro2, 'Color', 'r');
grid on;
xlabel('Time');
ylabel('Error');
title(['Mean Error POSY: ', num2str(erro_medio2)]);

figure(103);
subplot(311);
plot(x_values_truncado,P.VELX,'Color',sstgray);
hold on;
plot(x_values,x{1}(4,:),'Color',dcolors{1});
% hold on;
for iD = 2:nD
    plot(x_values_truncado,P.VELX,'Color',sstgray);
    plot(x_values,x{iD}(4,:),'Color',dcolors{iD});
end
hold off;
grid on;
ylabel('$$v_x(t)$$ [m/s]');
title('Drone velocity simulated and experimental');
subplot(312);
plot(x_values_truncado,P.VELY,'Color',sstgray);
hold on;
plot(x_values,x{1}(5,:),'Color',dcolors{1});
% hold on;
for iD = 2:nD
    plot(x_values_truncado,P.VELY,'Color',sstgray);
    plot(x_values,x{iD}(5,:),'Color',dcolors{iD});
end
hold off;
grid on;
ylabel('$$v_y(t)$$ [m/s]');

figure(104);
erro3=velocityx.GPS_Spd -x{1}(4,:);
erro_medio3 = abs(mean(velocityx.GPS_Spd) - mean(x{1}(4,:)));
% Plot do erro médio
subplot(311);
plot(x_values_truncado, erro3, 'Color', 'r');
grid on;
xlabel('Time');
ylabel('Error');
title(['Mean Error VELX: ', num2str(erro_medio3)]);

erro4=velocityY.XKF1_0__VD -x{1}(5,:);
erro_medio4 = abs(mean(velocityY.XKF1_0__VD) - mean(x{1}(5,:)));
% Plot do erro médio
subplot(312);
plot(x_values_truncado, erro4, 'Color', 'r');
grid on;
xlabel('Time');
ylabel('Error');
title(['Mean Error VELY: ', num2str(erro_medio4)]);
% subplot(313);
% plot(x_values,nu_ref{1}(3,:)*180/pi,'Color',sstgray);
% hold on;
% plot(x_values,x{1}(6,:)*180/pi,'Color',dcolors{1});
% % hold on;
% for iD = 2:nD
%     plot(x_values,nu_ref{iD}(3,:)*180/pi,'Color',sstgray);
%     plot(x_values,x{iD}(6,:)*180/pi,'Color',dcolors{iD});
% end
% hold off;
% grid on;
% xlabel('$$t$$ [s]');
% ylabel('$$\omega(t)$$ [deg/s]');
print2pdf([imgs_folder filename '_nu'],do_print);

if do_save_workspace
    save([saves_folder filename '.mat']);
end

% boat_animate(p,p_ref,lbd,t,dcolors);
