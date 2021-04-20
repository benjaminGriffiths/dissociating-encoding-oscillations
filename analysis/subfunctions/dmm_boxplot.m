function dmm_boxplot(data,y,collab);

% get number of participants
nsubj = size(data,1);

% sort subjects by magnitude
[~,idx] = sort(data);
data = data(idx);

% get boxplot parameters
boxparas.median     = mean(data);
boxparas.lowQuart   = data(round(nsubj/4));
boxparas.uppQuart   = data(round(3*nsubj/4));
boxparas.min        = min(data);
boxparas.max        = max(data);

% define colours
col_gray = [0.4 0.4 0.4];
cm_box  = flipud(brewermap(6,collab));

% plot boxplot
plot([y+0.2 y+0.8],repmat(boxparas.median,[1 2]),'k-','linewidth',1.5,'color',col_gray)
plot([y+0.3 y+0.7],repmat(boxparas.min,[1 2]),'k-','linewidth',1.5,'color',col_gray)
plot([y+0.3 y+0.7],repmat(boxparas.max,[1 2]),'k-','linewidth',1.5,'color',col_gray)
plot([y+0.5 y+0.5],[boxparas.uppQuart,boxparas.max],'k-','linewidth',1.5,'color',col_gray)
plot([y+0.5 y+0.5],[boxparas.lowQuart,boxparas.min],'k-','linewidth',1.5,'color',col_gray)
plot([y+0.2 y+0.2],[boxparas.lowQuart,boxparas.uppQuart],'k-','linewidth',1.5,'color',col_gray)
plot([y+0.8 y+0.8],[boxparas.lowQuart,boxparas.uppQuart],'k-','linewidth',1.5,'color',col_gray)
plot([y+0.2 y+0.8],repmat(boxparas.lowQuart,[1 2]),'k-','linewidth',1.5,'color',col_gray)
plot([y+0.2 y+0.8],repmat(boxparas.uppQuart,[1 2]),'k-','linewidth',1.5,'color',col_gray)
%for pp = 1 : nsubj; plot(y+1,data(pp),'ko','markerfacecolor',cm_box(3,:),'markeredgecolor','none'); end
