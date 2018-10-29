function [ fh, handle ] = show_stacked_maps( maps, varargin )
ip = inputParser;

addOptional(ip,'ygrid_stack',0);
addOptional(ip,'zgrid_stack',0);
addParamValue(ip, 'Comparison', 'off');
addParamValue(ip, 'Figure', 'new');
addParamValue(ip, 'MinColors', 9, @isnumeric);
addParamValue(ip, 'HRes', 640, @isnumeric);
addParamValue(ip, 'VRes', 480, @isnumeric);
addParamValue(ip, 'CutCorners', 0);
addParamValue(ip, 'PointCloud', 0);
addParamValue(ip, 'StripZeros', 1);


if ~nargin
    disp(ip.Parameters);
    return;
end

parse(ip, varargin{:});
ygrid_stack = ip.Results.ygrid_stack;
zgrid_stack = ip.Results.zgrid_stack;
comparison = ip.Results.Comparison;
fignum = ip.Results.Figure;
min_colors = ip.Results.MinColors;
hres = ip.Results.HRes;
vres = ip.Results.VRes;
cut = ip.Results.CutCorners;
point_size = ip.Results.PointCloud;
do_strip_zeros = ip.Results.StripZeros;

if ndims(maps) == 4
    ygrid_stack = maps(:,:,:,2);
    zgrid_stack = maps(:,:,:,3);
    maps = maps(:,:,:,1);
end


if (fignum)
    if ischar(fignum)
        fig = figure;
        clf;
    else
        fig = figure(fignum);
    end
end

any2 = @(x) any(x(:));
if ~iscell(ygrid_stack)
    if any2(ygrid_stack) 
        ygrid_stack = {ygrid_stack};
    end
end

if ~iscell(zgrid_stack)
    if any2(zgrid_stack) || numel(zgrid_stack) >1
        zgrid_stack = {zgrid_stack};
    end
end

if ~iscell(maps)
    maps = {maps};
end

if iscell(ygrid_stack)
    xgrid_stack = maps;
    maps = zgrid_stack;
end

if ~iscell(comparison)
    if ~ischar(comparison)
        if size(comparison,1) == 1 || size(comparison,2) == 1
            comparison = num2cell(comparison);
        else
            comparison = {comparison};
        end
    end
end

zlimits = [nan nan];
xlimits = [nan nan];
ylimits = [nan nan];

nanmin2 = @(x) nanmin(x(:));
nanmax2 = @(x) nanmax(x(:));


n_all_maps = 0;

for j = 1:numel(maps) 
    n_all_maps = n_all_maps + size(maps{j},3);
end
colors = distinguishable_colors(max(min_colors,n_all_maps));
colornum = 1;

for j = 1:numel(maps)

    nmaps = size(maps{j},3);
    ngridx = size(maps{j},2);
    ngridy = size(maps{j},1);

    h = zeros(1,nmaps);

    

    for i = 1:nmaps
        map = maps{j}(:,:,i);
        if do_strip_zeros
            map = double(map);
            map(map==0) = nan;
        end
        
        if iscell(ygrid_stack)
            ygrid = ygrid_stack{j}(:,:,i);
            xgrid = xgrid_stack{j}(:,:,i);
        else
            x_vector = ((((1:ngridx) - 0.5)/ngridx) * hres);
            y_vector = ((((1:ngridy) - 0.5)/ngridy) * vres);
            [xgrid, ygrid] = meshgrid(x_vector, y_vector);
        ylimits = [nanmin2([ylimits(1),0])  nanmax2([ylimits(2),vres])];
        xlimits = [nanmin2([xlimits(1),0])  nanmax2([xlimits(2),hres])];
        end
        
        nanidx = isnan(xgrid) | isnan(ygrid) | isnan(map);
        xgrid(nanidx) = nan;
        ygrid(nanidx) = nan;
        map(nanidx) = nan;
        
        zgrid = map_cut_corners(map,cut);
        
        if point_size
            h(i) = plot3(double(xgrid(:)),double(ygrid(:)),double(zgrid(:)),...
                '.','markersize',point_size,'MarkerEdgeColor',colors(colornum,:));
        else
            h(i) = mesh(double(xgrid),double(ygrid),double(zgrid),'EdgeColor',colors(colornum,:));
        end
        colornum = colornum+1;
        hold on;
        
        zlimits = [nanmin2([zlimits(1),nanmin2(map)])  nanmax2([zlimits(2),nanmax2(map)])];
        ylimits = [nanmin2([ylimits(1),nanmin2(ygrid)])  nanmax2([ylimits(2),nanmax2(ygrid)])];
        xlimits = [nanmin2([xlimits(1),nanmin2(xgrid)])  nanmax2([xlimits(2),nanmax2(xgrid)])];
    end
end
if iscell(comparison)
    for j = 1:numel(comparison)
    
        if size(comparison{j},1) == 1 || size(comparison{j},2) == 1
            comparison{j} = repmat(reshape(comparison{j}(:),1,1,numel(comparison{j})),2,2);
        end
        
        
        for i = 1:size(comparison{j},3)
            map = comparison{j}(:,:,i);
            
            ngridx = size(comparison{j},2);
            ngridy = size(comparison{j},1);
            
            edges = 'none';
            if iscell(ygrid_stack)
                ygrid = ygrid_stack{j}(:,:,i);
                xgrid = xgrid_stack{j}(:,:,i);
            else
                if size(map,1) == 2
                    edges = 'k';
                    x_vector = [0 hres];
                    y_vector = [0 vres];
                    [xgrid, ygrid, ] = meshgrid(x_vector, y_vector);
                else
                    x_vector = ((((1:ngridx) - 0.5)/ngridx) * hres);
                    y_vector = ((((1:ngridy) - 0.5)/ngridy) * vres);
                    [xgrid, ygrid] = meshgrid(x_vector, y_vector);
                end
            end
            
        nanidx = isnan(xgrid) | isnan(ygrid) | isnan(map);
        xgrid(nanidx) = nan;
        ygrid(nanidx) = nan;
        map(nanidx) = nan;
            
            if strcmp(edges,'none')
                map_outlines = bwboundaries(imfill(~isnan(map),'holes'));

                for region = 1:numel(map_outlines)
                    idx = sub2ind(size(map),map_outlines{region}(:,1),map_outlines{region}(:,2));
                    plot3(double(xgrid(idx)),double(ygrid(idx)),double(map(idx)),'k-');
                end
            end
            
            surf(double(xgrid),double(ygrid),double(map),'edgecolor',edges,'FaceColor',[0.5 0.5 0.5]);
            alpha(0.6);
            zlimits = [nanmin2([zlimits(1),nanmin2(map)])  nanmax2([zlimits(2),nanmax2(map)])];
            ylimits = [nanmin2([ylimits(1),nanmin2(ygrid)])  nanmax2([ylimits(2),nanmax2(ygrid)])];
            xlimits = [nanmin2([xlimits(1),nanmin2(xgrid)])  nanmax2([xlimits(2),nanmax2(xgrid)])];
        end
    end
end

try zlim(double(zlimits)); catch; zlim('auto'); end;
try xlim(double(xlimits)); catch; xlim('auto'); end; 
try ylim(double(ylimits)); catch; ylim('auto'); end;  

hold off;
if nargout
    fh = fig;
end
if nargout>1
    handle = h;
end
end

