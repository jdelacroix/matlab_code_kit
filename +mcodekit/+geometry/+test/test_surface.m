function test_surface()

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

view = axes();
axis(view, 'square')
axis(view, [-2 2 -2 2]);
hold(view, 'on')


surface_a = [ 0 0; 1 1; 0 1 ];
surface_b = [0.5 0; 1.5 0; 1.5 1; 0.5 1];
h_surface_a = patch('Parent', view, 'Vertices', surface_a, 'Faces', 1:size(surface_a,1), 'FaceColor', [1 0.8 0.8]);
h_surface_b = patch('Parent', view, 'Vertices', surface_b, 'Faces', 1:size(surface_b,1), 'FaceColor', [0.8 0.8 1]);

sf_a = mcodekit.geometry.Surface2D(surface_a);
sf_b = mcodekit.geometry.Surface2D(surface_b);

p_ab = sf_a.intersection_with_surface(sf_b);
p_ab_i = p_ab.get_iterator();
fprintf('# of intersections; %d\n', p_ab.size_);
while (p_ab_i.has_next())
    p = p_ab_i.next();
    fprintf('point of intersection: (%0.3g, %0.3g)\n', p.v_);
end

pause;

delete(h_surface_a);
delete(h_surface_b);

surface_a = [ 0 0; 1 1; 0 1 ];
surface_b = [0.5 0; 1.5 0; 1.5 1];
h_surface_a = patch('Parent', view, 'Vertices', surface_a, 'Faces', 1:size(surface_a,1), 'FaceColor', [1 0.8 0.8]);
h_surface_b = patch('Parent', view, 'Vertices', surface_b, 'Faces', 1:size(surface_b,1), 'FaceColor', [0.8 0.8 1]);

sf_a = mcodekit.geometry.Surface2D(surface_a);
sf_b = mcodekit.geometry.Surface2D(surface_b);

p_ab = sf_a.intersection_with_surface(sf_b);
p_ab_i = p_ab.get_iterator();
fprintf('# of intersections: %d\n', p_ab.size_);
while (p_ab_i.has_next())
    p = p_ab_i.next();
    fprintf('point of intersection: (%0.3g, %0.3g)\n', p.v_);
end

pause;

delete(h_surface_a);
delete(h_surface_b);
delete(view);
delete(gcf);

end

