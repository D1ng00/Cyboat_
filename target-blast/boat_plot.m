% NOVA School of Science and Technology
% Bruno Guerreiro (bj.guerreiro@fct.unl.pt)
function handle = boat_plot(eta,handle,dcolor)
% plots a drone given its pose information. 

    if ~exist('eta','var') || isempty(eta)
        eta= zeros(3,1);
    end
    if ~exist('handle','var') || isempty(handle)
        handle = zeros(1,1);
        is_first = 1;
    else
        is_first = 0;
    end
    if ~exist('dcolor','var') || isempty(dcolor)
        dcolor = [1,0,0];
    end
    
    internal_rot_axis = Euler2R([pi;0;0]);
    scale = 1;

    pos = [eta(1:2);0];
    lbd = [0;0;eta(3)];
        
    rot = Euler2R(lbd)*internal_rot_axis;
    pos = pos';
        
    % draw main body:
    handle = draw_main_body(rot,pos,scale,dcolor,handle,is_first);

end

function handles = draw_main_body(rot,pos,scale,dcolor,handles,is_first)
    
    raw_top = [ -0.2   0.039 0   
                 0.0   0.041 0
                 0.1   0.042 0
                 0.2   0.040 0
                 0.25  0.036 0
                 0.3   0.029 0
                 0.35  0.019 0
                 0.403 0.0   0
                 0.35 -0.019 0 
                 0.3  -0.029 0 
                 0.25 -0.036 0 
                 0.2  -0.040 0  
                 0.1  -0.042 0  
                 0.0  -0.041 0
                -0.2  -0.039 0];
    pts_boat = ((rot*(raw_top*scale)')' + ...
                kron(ones(size(raw_top,1),1),pos))';
            
    vert = pts_boat(:,1:15)';
    face = 1:15;
    
    if ~is_first
%         set(handles(1,:),'xdata',pts_tri(1,:),'ydata',pts_tri(2,:),'zdata',pts_tri(3,:));
        set(handles(1,:),'Vertices',vert);
    else
%         handles(1,:) = plot3(pts_tri(1,:),pts_tri(2,:),pts_tri(3,:),'LineWidth',0.6,'Color',dcolor);
        handles(1,:) = patch('Faces',face,'Vertices',vert,'FaceColor',dcolor);
    end
    
end