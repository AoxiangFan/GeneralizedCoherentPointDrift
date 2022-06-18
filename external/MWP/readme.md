# Efficient deformable shape correspondence via multiscale spectral manifold wavelets preservation

This is the Matlab implementation for the paper 'Efficient deformable shape correspondence via multi-scale spectral manifold wavelets preservation' by Ling Hu, Qinsong Li, Shengjun Liu and Xinru Liu accepted by CVPR 2021.

In this paper, we have presented a novel approach for shape correspondence that incorporated novel constraints into the functional map framework. The core idea is that multi-scale spectral manifold wavelets are required to be preserved at each scale respectively in the functional maps. Such constraints have been proven to be able to strongly ensure the isometric of the underlying point-wise maps. 

![shrec16_partial_cqc_vis_svg3](https://github.com/Qinsong-Li/MWP/blob/main/iter_results.png)



# How to use this code

We have provided two core functions:

1. MWP.m 
2. MWP_fast.m 

and two demos for full shape matching('MWP_demo_full_matching.m') and partial shape matching ('MWP_demo_partial_matching'). gptoolbox and gspbox are needed to add to the matlab path for pre-computing data.

- gptoolbox: https://github.com/alecjacobson/gptoolbox

- gspbox: https://github.com/epfl-lts2/gspbox 

If you have any questions, please contact me. [qinsli.cg@foxmail.com](mailto:qinsli.cg@foxmail.com) (Qinsong Li)

# License

This work is licensed under a [Creative Commons Attribution-NonCommercial 4.0 International License](http://creativecommons.org/licenses/by-nc/4.0/). For any commercial uses or derivatives, please contact us ([shjliu.cg@csu.edu.cn](mailto:shjliu.cg@csu.edu.cn), [qinsli.cg@foxmail.com](mailto:qinsli.cg@foxmail.com)).



