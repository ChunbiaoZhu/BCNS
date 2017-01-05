% Matlab demo 
close all;clear;
addpath('./src');
imgRoot='./data/image/';%% test image dir
imgRootFE='./data/FE/';%% flashEnhance image dir
imgRootBSC='./data/BSCA/';%% center-bias image dir
imnames=dir([imgRoot '*' 'png']);
imnamesFE=dir([imgRootFE '*' 'png']);
imnamesBSC=dir([imgRootBSC '*' 'png']);
for ii=1:length(imnames);
    imname=[imgRoot imnames(ii).name]; 
    imnameFE=[imgRootFE imnamesFE(ii).name]; 
    imnameBSC=[imgRootBSC imnamesBSC(ii).name]; 
    RGB_img=imread(imname); 
    RGB_imgFE=imread(imnameFE); 
    RGB_imgBSC=imread(imnameBSC); 

      
% image set path
img_name = imname;
% RGB_path= input_im;
Depth_path= ['./data/depth/' imnames(ii).name(1:end-4) '_depth.png'];
Result_path = FDS_mkdir('./data/BCSN/');
% parameters
BCSN_para.cluster_num= 40; %clustering number 
BCSN_para.sigma2 = 0.4;
BCSN_para.gamma = 1;

depth_map = double(imread(Depth_path));

[BCSN_para.img_H, BCSN_para.img_W, BCSN_para.img_C] = size(RGB_img); 
BCSN_para.img_vector_size = BCSN_para.img_H* BCSN_para.img_W; 
RGB_img = mat2gray(RGB_img);
RGB_imgFE = mat2gray(RGB_imgFE);
RGB_img = (RGB_img+RGB_imgFE).*255;
% compute cluster-based saliency cue
BCSN_Cue = BCSN_SaliencyCue( RGB_img, depth_map, BCSN_para );

BCSN_Cue.FinalCue = BCSN_GaussNorm((BCSN_Cue.Dep)+(BCSN_Cue.Center));

% generate saliency map  
BCSN_map = BCSN_GenerateMap(BCSN_para, BCSN_Cue);

depth_temp = round((depth_map - min(depth_map(:)))./(max(depth_map(:)) - min(depth_map(:))).*255);
imwrite(BCSN_map, [Result_path imnames(ii).name(1:end-4) '.jpg'], 'jpg');
[M,N] = size(depth_temp);
Sd = zeros(M,N);
 depth_temp=255-depth_temp;
mx = max(max(depth_temp));
BCSN_map = mat2gray(BCSN_map);
depth_temp = mat2gray(depth_temp);
RGB_imgBSC = im2double(RGB_imgBSC);
RGB_imgBSC = mat2gray(RGB_imgBSC);
BCSN_map = BCSN_map.*depth_temp.*RGB_imgBSC;

% save result
imwrite(BCSN_map, [Result_path imnames(ii).name(1:end-4) '.png'], 'png');

end