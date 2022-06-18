function [p,c]=mplot_mesh_rgb(verts,faces,rgb)
% figure;
% view(-90,0);% dog
% view(-75,0);% cat5
% view(0,0);%gorilla1
% view(-30,25);%cat0
% view(-50,10);%horse0
% view(20,0);%kid00
% view(0,90);%faust
% view(-160,0);%heart
% view(-90,10);
view(-60,30);
p=patch('Vertices',verts,'Faces',faces,'FaceVertexCData',rgb,...
'FaceColor','interp','EdgeColor','none','FaceLighting','gouraud');
axis equal;axis off;
camproj('persp');
c=camlight('left');
material([.5 .5 0.2 25 0]);