classdef Surface2D < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        vertex_set_
        edge_set_
        centroid_
        geometry_
        handle_
    end
    
    methods
        function obj = Surface2D(varargin)
            switch(nargin)
                case 1,
                    obj.geometry_ = varargin{1};
                case 2,
                    obj.handle_ = varargin{1};
                    obj.geometry_ = varargin{2};
                otherwise
                    error('expected 1 or 2 arguments');
            end
            geometry = obj.geometry_;
            
            % create the vertex set
            obj.vertex_set_ = mcodekit.list.dl_list();
            for k = 1:size(geometry, 1)
                obj.vertex_set_.append_key(mcodekit.geometry.Vector2D(geometry(k,1), geometry(k,2)));
            end
            
            % create the edge set
            obj.edge_set_ = mcodekit.list.dl_list();
            n = size(geometry, 1);
            for k = 1:n
                point_a = mcodekit.geometry.Vector2D(geometry(k,1), geometry(k,2));
                point_b = mcodekit.geometry.Vector2D(geometry(mod(k,n)+1,1), geometry(mod(k,n)+1,2));
                obj.edge_set_.append_key(mcodekit.geometry.Line2D(point_a, point_b));
            end
            
            % compute the surface's centroid
            obj.centroid_ = mcodekit.geometry.Vector2D(mean(geometry(:,1:2)));
        end
        
        function points = intersection_with_surface(obj, surface)
            points = mcodekit.list.dl_list();
            
            % iterate over this surface's edge set
            edge_set_iter = obj.edge_set_.get_iterator();
            while (edge_set_iter.has_next())
                edge_a = edge_set_iter.next();
%                 fprintf('edge a: (%0.3g,%0.3g)->(%0.3g,%0.3g)\n', edge_a.point_a_.v_, edge_a.point_b_.v_);

                line_a = [edge_a.point_a_.v_; edge_a.point_b_.v_];
                
                % iterate over the other surface's edge set
                edge_set_b = surface.edge_set_.get_iterator();
                while (edge_set_b.has_next())
                    edge_b = edge_set_b.next();
                    
%                     fprintf('edge b: (%0.3g,%0.3g)->(%0.3g,%0.3g)\n', edge_b.point_a_.v_, edge_b.point_b_.v_);
                    
                    line_b = [edge_b.point_a_.v_; edge_b.point_b_.v_];
                    
                    point_set_x = [line_a(:,1) line_b(:,1)];
                    point_set_y = [line_a(:,2) line_b(:,2)];
                    
                    diff_set_x = diff(point_set_x);
                    diff_set_y = diff(point_set_y);
                    
                    diff_set_x_t = -diff(point_set_x');
                    diff_set_y_t = -diff(point_set_y');
                    
                    var_ab_d = det([diff_set_x; diff_set_y]);
                    var_a_n = diff_set_x(2)*diff_set_y_t(1)-diff_set_y(2)*diff_set_x_t(1);
                    var_a = var_a_n/var_ab_d;
                    var_b_n = diff_set_x(1)*diff_set_y_t(1)-diff_set_y(1)*diff_set_x_t(1);
                    var_b = var_b_n/var_ab_d;
                    
                    point_x = point_set_x(1)+var_a*diff_set_x(1);
                    point_y = point_set_y(1)+var_a*diff_set_y(1);
                    
%                     if((var_a_n == 0 && var_b_n == 0) && var_ab_d == 0)
%                         fprintf('edge are coincident\n');
%                     elseif (var_ab_d == 0)
%                         fprintf('edges are parallel\n');
%                     else
                        is_point_in_segment = (0 <= var_a && var_a <= 1) && (0 <= var_b && var_b <= 1);
                        if(is_point_in_segment)
                            points.append_key(mcodekit.geometry.Vector2D(point_x, point_y));
%                         else
%                             fprintf('intersection point is not in any line segment\n');
                        end
%                     end
                end
            end
        end
        
        
        
        function bool = point_in_surface(obj, point)
            theta_sum = 0;
            
            % iterate over this surface's vertices
            vertex_a = obj.vertex_set_.head_;
            while (~isempty(vertex_a))
                
                % iterate over this surface's other vertices
                vertex_b = vertex_a.next_;
                if (isempty(vertex_b))
                    vertex_b = obj.vertex_set_.head_;
                end
                
                % compute the angle between the test point and a pair of
                % two vertices from the surface.
                v_a = vertex_a.key_.v_;
                v_b = vertex_b.key_.v_;
                
                v_pa = [v_a(1)-point.v_(1), v_a(2)-point.v_(2)];
                v_pb = [v_b(1)-point.v_(1), v_b(2)-point.v_(2)];
                
                theta_pa = atan2(v_pa(2), v_pa(1));
                theta_pb = atan2(v_pb(2), v_pb(1));
                
                dtheta = theta_pb-theta_pa;
                dtheta = atan2(sin(dtheta), cos(dtheta));
                theta_sum = theta_sum + dtheta;

                vertex_a = vertex_a.next_;
            end
            
            % check if theta_sum is 0 or else the point is in this surface
            epsilon = 1e-6;
            if (abs(theta_sum) < epsilon)
                bool = false;
            else
                bool = true;
            end
        end
    end
    
end

