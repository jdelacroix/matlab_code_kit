classdef Vector2D < handle
% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties (Access = private)
        x_
        y_
    end
    
    properties (Dependent = true)
        v_
    end
    
    methods
        function obj = Vector2D(varargin)
            if nargin == 1
                obj.x_ = varargin{1}(1);
                obj.y_ = varargin{1}(2);
            elseif nargin == 2
                obj.x_ = varargin{1};
                obj.y_ = varargin{2};
            else
                error('unexpected format input: Vector2D([x,y]) or Vector2D(x,y)');
            end
        end
        
        function v = get.v_(obj)
            v = [obj.x_, obj.y_];
        end
        
        function set.v_(obj, v)
            obj.x_ = v(1);
            obj.y_ = v(2);
        end
        
        function vector_2d_n = normal(obj)
            v = obj.v_;
            vector_2d_n = mcodekit.geometry.Vector2D(-v(2), v(1));
        end
        
        function vector_2d_i = inverse(obj)
            v = obj.v_;
            vector_2d_i = mcodekit.geometry.Vector2D(-v(1), -v(2));
        end
        
    end
    
    methods (Static)
        function vector_2d_p = triple_vector_product(vector_a, vector_b, vector_c)
            % triple vector product: (AxB)xC = (C.A)*B-(C.B)*A
            v_p = dot(vector_c, vector_a)*vector_b-dot(vector_c, vector_b)*vector_a;
            vector_2d_p = mcodekit.geometry.Vector2D(v_p);
        end
    end
    
end