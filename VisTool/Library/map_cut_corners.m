function [ maps ] = map_cut_corners( maps, extent )
% maps is m x n x p, extent is an integer, this NaNs corners

for i = 1:extent
maps(1:1+extent-i,i,:) = NaN;
maps(end-(extent-i):end,i,:) = NaN;
maps(1:1+extent-i,end-i+1,:) = NaN;
maps(end-(extent-i):end,end-i+1,:) = NaN;
end

