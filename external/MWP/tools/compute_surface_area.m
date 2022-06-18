function A = compute_surface_area(vertices,faces)

A = 0;
for i = 1:length(faces)
    A_i = norm(cross(vertices(faces(i,2),:)-vertices(faces(i,1),:),...
        vertices(faces(i,3),:)-vertices(faces(i,1),:)));
    A = A + A_i;
end
A = A/2;