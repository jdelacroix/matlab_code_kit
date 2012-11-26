classdef GjkCollisionDetector < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

% Implemented with help from skeleton code on William Bittle's blog:
% URL: http://www.codezealot.org/archives/88#gjk-support
    
    properties
        
    end
    
    methods
        
        function bool = detect_collision(obj, g_surface_a, g_surface_b)
            % construct surfaces from input geometry
            surface_a = mcodekit.geometry.Surface2D(g_surface_a);            
            surface_b = mcodekit.geometry.Surface2D(g_surface_b);
            
            % pick the vector between the centroid of the two surfaces
            direction = mcodekit.geometry.Vector2D(surface_b.centroid_.v_-surface_a.centroid_.v_);
            
            % start constructing a {1,2,3}-simplex
            simplex = mcodekit.list.dl_list();
            support_point = obj.support(surface_a, surface_b, direction);
            simplex.append_key(support_point);
            direction.v_ = direction.inverse().v_;
            
            % loop until terminating condition is met
            while (true)
                support_point = obj.support(surface_a, surface_b, direction);
                simplex.append_key(support_point);
                point = simplex.get_last_key();
                if (dot(point.v_, direction.v_) <= 0)
                    bool = false;
                    return;
                else
                    if(obj.simplex_contains_origin(simplex, direction))
                       bool = true;
                       return;
                    end
                end
            end
        end
        
        function bool = simplex_contains_origin(obj, simplex, direction)
            % compute vector from the last point to the origin
            point_a = simplex.get_last_key();
            vector_ao = [0,0]-point_a.v_;
            
%             fprintf('%d-simplex\n', simplex.size_)
            if (simplex.size_ < 3)
                point_b = simplex.get_key(1);
                
                % compute vector from A to B and its perpendicular
                vector_ab = point_b.v_ - point_a.v_;
                vector_ab_p = mcodekit.geometry.Vector2D.triple_vector_product(vector_ab, vector_ao, vector_ab).v_;
                if (vector_ab_p(1) == 0 && vector_ab_p(2) == 0)
                    vector_ab_p = mcodekit.geometry.Vector2D(vector_ab).normal().v_;
                end
                direction.v_ = vector_ab_p;
%                 fprintf('new direction vector: [%0.3f, %0.3f]\n', direction.vector);
                bool = false;
                
            else % (simplex.size_ == 3)
                point_b = simplex.get_key(2);
                point_c = simplex.get_key(1);
                
                vector_ab = point_b.v_-point_a.v_;
                vector_ac = point_c.v_-point_a.v_;
                
                vector_ab_p = mcodekit.geometry.Vector2D.triple_vector_product(vector_ac, vector_ab, vector_ab).v_;
                vector_ac_p = mcodekit.geometry.Vector2D.triple_vector_product(vector_ab, vector_ac, vector_ac).v_;
                
%                 vector_ab_p = mcodekit.geometry.Vector2D.triple_vector_product(vector_ab, vector_ao, vector_ab).v_;
%                 vector_ac_p = mcodekit.geometry.Vector2D.triple_vector_product(vector_ac, vector_ao, vector_ac).v_;
                
                if (dot(vector_ac_p, vector_ao) >= 0)
                    simplex.remove_key(2);
%                     if (vector_ac_p(1) == 0 && vector_ac_p(2) == 0)
%                         vector_ac_p = mcodekit.geometry.Vector2D(vector_ac).normal().v_;
%                     end
                    direction.v_ = vector_ac_p;
%                     fprintf('new direction vector: [%0.3f, %0.3f] from AC\n', direction.v_);
                    bool = false;
                elseif (dot(vector_ab_p, vector_ao) >= 0)
                    simplex.remove_key(1);
%                     if (vector_ab_p(1) == 0 && vector_ab_p(2) == 0)
%                         vector_ab_p = mcodekit.geometry.Vector2D(vector_ab).normal().v_;
%                     end
                    direction.v_ = vector_ab_p;
%                     fprintf('new direction vector: [%0.3f, %0.3f] from AB\n', direction.v_);
                    bool = false;
                else
                    bool = true;
                end
            end
        end
        
        function point = support(obj, surface_a, surface_b, direction)
            point_a = obj.farthest_point_in_direction(surface_a, direction);
%             fprintf('closest point (%0.3f, %0.3f) of A in direction [%0.3f, %0.3f]\n', point_a.vector, direction.vector);
            point_b = obj.farthest_point_in_direction(surface_b, direction.inverse());
%             fprintf('closest point (%0.3f, %0.3f) of B in direction [%0.3f, %0.3f]\n', point_b.vector, -direction.vector);
            point = mcodekit.geometry.Vector2D(point_a.v_-point_b.v_);
        end
        
        function point = farthest_point_in_direction(obj, surface, direction)
            k = surface.vertex_set_.get_iterator();
            point = k.next();
            distance = dot(point.v_, direction.v_);
            while(k.has_next())
                test_point = k.next();
                test_distance = dot(test_point.v_, direction.v_);
                if (test_distance > distance)
                    distance = test_distance;
                    point = test_point;
                end
            end
        end
    end
    
end

