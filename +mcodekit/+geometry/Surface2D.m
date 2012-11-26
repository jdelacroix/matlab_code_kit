classdef Surface2D < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        vertices_
        centroid_
    end
    
    methods
        function obj = Surface2D(geometry)
            obj.vertices_ = mcodekit.list.dl_list();
            for k = 1:size(geometry, 1)
                obj.vertices_.append_key(mcodekit.geometry.Vector2D(geometry(k,1), geometry(k,2)));
            end
            obj.centroid_ = mcodekit.geometry.Vector2D(mean(geometry(:,1:2)));
        end
    end
    
end

