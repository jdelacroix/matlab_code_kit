classdef Line2D < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        point_a_
        point_b_
    end
    
    methods
        function obj = Line2D(point_a, point_b)
            obj.point_a_ = point_a;
            obj.point_b_ = point_b;
        end        
    end
    
end

