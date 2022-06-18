function mplot_boundary(V,F)
TR=triangulation(F,V);
[BF,BV]=TR.freeBoundary;
bX=BV(:,1);
bY=BV(:,2);
bZ=BV(:,3);
hold on;

for s=1:size(BF,1)
    f1=BF(s,1);
    f2=BF(s,2);
    plot3([bX(f1);bX(f2)],[bY(f1);bY(f2)],[bZ(f1);bZ(f2)],'-r','LineWidth',2);
end
hold off;