%%%
% this script generates the feature stimuli
%%%

clearvars
clc

% define image parameters
img_size = [1200 1200];

% define colours
colors = [217 150 148;... % red
          085 142 213;... % dark blue
          185 205 229;... % light blue
          195 214 155;... % green
          179 162 199;... % purple
          250 192 144;... % orange
          255 255 255;... % white
          191 191 191;... % grey
          000 000 000]./255; % black
      
% define template chequered feature
cheq                = ones(img_size/8);
cheq_size           = size(cheq);
feat_tpl.chequered	= zeros(img_size);

% cycle through each position and add cheq
for i = 1  : size(feat_tpl.chequered,1) / size(cheq,1)
    for j = 2+(mod(i,2)*-1) : 2 : size(feat_tpl.chequered,1) / size(cheq,1)
        x = 1 + (cheq_size(1)*(i-1)) : cheq_size(1) * i;
        y = 1 + (cheq_size(1)*(j-1)) : cheq_size(1) * j;
        feat_tpl.chequered(x,y) = cheq;
    end
end

% add black border
boundary  = img_size(1)*0.01:img_size(1)-(img_size(1)*0.01);
borderImg = zeros(img_size);
borderImg(boundary,boundary) = ones(numel(boundary),numel(boundary));
feat_tpl.chequered	= feat_tpl.chequered .* borderImg;

% define template polkadot feature
[x,y]               = meshgrid(1:img_size/8, 1:img_size/8);
circimg             = (x - (max(x(1,:))/2)).^2 + (y - (max(x(1,:))/2)).^2 <= (max(x(1,:))/2).^2;
circ_size           = size(circimg);
feat_tpl.polkadot   = zeros(img_size);

% cycle through each position and add cheq
for i = 1  : size(feat_tpl.chequered,1) / size(cheq,1)
    for j = 2+(mod(i,2)*-1) : 2 : size(feat_tpl.chequered,1) / size(cheq,1)
        x = 1 + (circ_size(1)*(i-1)) : circ_size(1) * i;
        y = 1 + (circ_size(1)*(j-1)) : circ_size(1) * j;
        feat_tpl.polkadot(x,y) = circimg;
    end
end

% define colour pairs
cp = nchoosek((1:size(colors,1)),2);
cp = [cp; fliplr(cp)];

% start counter
count = 0;

% cycle through each pair
for i = 1 : size(cp,1)
    
    % create chequred feature
    img = zeros(numel(img_size),3);
    img(feat_tpl.chequered==1,1) = colors(cp(i,1),1);
    img(feat_tpl.chequered==1,2) = colors(cp(i,1),2);
    img(feat_tpl.chequered==1,3) = colors(cp(i,1),3);
    img(feat_tpl.chequered==0,1) = colors(cp(i,2),1);
    img(feat_tpl.chequered==0,2) = colors(cp(i,2),2);
    img(feat_tpl.chequered==0,3) = colors(cp(i,2),3);
    img = reshape(img,[img_size,3]);
    
    % save chequered image
    imwrite(img,['E:\bjg335\projects\epi_mem_demands\experiment\stimuli\image_feature\chequered_',sprintf('%02.0f',i),'.jpg'])
    
    % create polkadot feature
    img = zeros(numel(img_size),3);
    img(feat_tpl.polkadot==1,1) = colors(cp(i,1),1);
    img(feat_tpl.polkadot==1,2) = colors(cp(i,1),2);
    img(feat_tpl.polkadot==1,3) = colors(cp(i,1),3);
    img(feat_tpl.polkadot==0,1) = colors(cp(i,2),1);
    img(feat_tpl.polkadot==0,2) = colors(cp(i,2),2);
    img(feat_tpl.polkadot==0,3) = colors(cp(i,2),3);
    img = reshape(img,[img_size,3]);
    
    % add circle border to polka dot
    [x,y]	= meshgrid(1:img_size, 1:img_size);
    circimg	= repmat((x - (max(x(1,:))/2)).^2 + (y - (max(x(1,:))/2)).^2 <= (max(x(1,:))/2).^2,[1 1 3]);
    img(circimg==0) = 1;
    
    % save polkadot image
    imwrite(img,['E:\bjg335\projects\epi_mem_demands\experiment\stimuli\image_feature\polkadot_',sprintf('%02.0f',i),'.jpg'])
    
    count = count + 1;
    if count == 64; break; end
end
    