function T12 = callZoomOutSinkhorn(file1, file2, T12_ini)

k = 100;
S1 = MESH.preprocess(file1, 'IfComputeLB',true, 'numEigs',k);
S2 = MESH.preprocess(file2, 'IfComputeLB',true, 'numEigs',k);

numIter = 5;
[T12, ~] = zoomout_refine(S1.evecs, S2.evecs, T12_ini, numIter, 'sinkhorn');

