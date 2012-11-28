classdef StochasticSystem < handle
    %STOCHASTIC_SYS A stochastic system.
    
    % Copyright (C) 2012 Jean-Pierre de la Croix
    % see the LICENSE file included with this software
    
    properties
        sigma_w         % w_k state noise standard deviation
        sigma_n         % n_k measurement standard deviation
        
        Ds              % dimension of the state space
        Dm              % dimension of the measurement space
    end
    
    methods
        function obj = StochasticSystem(sigma_2_w, sigma_2_n, Ds, Dm)
            % 0. Validate input parameters.           
            assert(sigma_2_w >= 0, 'state noise variance must be >= 0');
            obj.sigma_w = sqrt(sigma_2_w);
            
            assert(sigma_2_n >= 0, 'measurement noise variance must be >= 0');
            obj.sigma_n = sqrt(sigma_2_n);
            
            assert(round(Ds)>=1, 'dimension of state space must be at least 1');
            obj.Ds = round(Ds);
            
            assert(round(Dm)>=1, 'dimension of measurement space must be at least 1');
            obj.Dm = round(Dm);
        end
        
        % 1. Define state update equation.
        function x_k = f_state(obj, x_k_1, w_k_1, k)
           x_k = 1/2*x_k_1+25*x_k_1/(1+x_k_1^2)+8*cos(1.2*(k-1))+w_k_1;
        end
        
        % 2. Define measurement update equation
        function z_k = h_meas(obj, x_k, n_k, k)
           z_k = 1/20*x_k^2+n_k;
        end
        
        % 3. Define Jacobian of state update equation.
        function J_f_x = jacobian_f_state_x(obj, x_k_1, k)
            J_f_x = 25/(x_k_1^2 + 1)-(50*x_k_1^2)/(x_k_1^2+1)^2+1/2;
        end
        
        % 4. Define Jacobian of measurement update equation.
        function J_f_h = jacobian_h_meas_x(obj, x_k, k)
            J_f_h = 1/10*x_k^2;
        end
        
        % 5. Define state and measurement noise distributions.
        function pr_w_k_1 = pdf_state_noise(obj, w_k_1)
            pr_w_k_1 = normpdf(w_k_1, 0, obj.sigma_w);
        end
        
        function w_k = sample_state_noise(obj)
            w_k = normrnd(0, obj.sigma_w, obj.Ds, 1);
        end
        
        function pr_n_k = pdf_meas_noise(obj, n_k)
            pr_n_k = normpdf(n_k, 0, obj.sigma_n);
        end
        
        function n_k = sample_meas_noise(obj)
            n_k = normrnd(0, obj.sigma_n, obj.Dm, 1);
        end
    end
    
end

