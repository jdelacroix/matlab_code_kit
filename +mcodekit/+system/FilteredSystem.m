classdef FilteredSystem < handle
    %FILTERED_SYS A filtered system.
    
    % Copyright (C) 2012 Jean-Pierre de la Croix
    % see the LICENSE file included with this software
    
    properties
        
        x_k             % x_k state of system at step k
        z_k             % z_k state of system at step k
        
        x_h_k           % x_h_k filtered state of system at step k
        z_h_k           % z_h_k filtered measurement of system as step k
        
        w_k             % w_k state noise of system at step k
        n_k             % n_k measurement noise of system at step k
        
        N               % total # of steps
        
        fltr            % discrete filter (EKF or particle)
        sys             % discrete stochastic system
        
        Ds              % dimension of the state space
        Dm              % dimension of the measurement space
    end
    
    methods
        
        function obj = FilteredSystem(sys, fltr, N, x_0, x_h_0)
            % 0. Validate input parameters.
            assert(isa(sys, 'mcodekit.system.StochasticSystem'), 'sys must be a stochastic system');
            obj.sys = sys;
            
            assert(isa(fltr, 'mcodekit.algorithm.ExtendedKalmanFilter') || isa(fltr, 'mcodekit.algorithm.ParticleFilter'), 'fltr must be a filter');
            obj.fltr = fltr;
            
            obj.Ds = sys.Ds;
            obj.Dm = sys.Dm;
            
            obj.N = fltr.N;
            
            % 1. Initialize the filtered system.
            k = 1;
            
            obj.w_k = zeros(obj.Ds,N);
            obj.w_k(:,k) = zeros(obj.Ds,1);
            
            obj.n_k = zeros(obj.Dm,N);
            obj.n_k(:,k) = sys.sample_meas_noise();
            
            obj.x_k = zeros(obj.Ds,N);
            obj.x_k(:,k) = x_0;
            
            obj.x_h_k = zeros(obj.Ds,N);
            obj.x_h_k(:,k) = x_h_0;
            
            obj.z_k = zeros(obj.Dm,N);
            obj.z_k(:,k) = sys.h_meas(obj.x_k(:,k), obj.n_k(:,k), k);
            
            obj.z_h_k = zeros(obj.Dm,N);
            obj.z_h_k(:,k) = sys.h_meas(obj.x_h_k(:,k), 0, k);
        end
        
        % 2. Simulate the filtered system.
        function simulate(obj)
            for k=2:obj.N
                
                % 2.1 Simulate the stochastic system
                obj.w_k(:,k) = obj.sys.sample_state_noise();
                obj.n_k(:,k) = obj.sys.sample_meas_noise();
                obj.x_k(:,k) = obj.sys.f_state(obj.x_k(:,k-1), obj.w_k(:,k-1), k);
                obj.z_k(:,k) = obj.sys.h_meas(obj.x_k(:,k), obj.n_k(:,k), k);
                
                % 2.2 Apply the filter.
                [obj.x_h_k(:,k), obj.z_h_k(:,k)] = obj.fltr.apply_filter(obj.x_k(:,k-1), obj.z_k(:,k), k);
            end
        end
        
        % 3. Plot the result.
        function print(obj)
            figure;
            As = axes();
            hold(As, 'on');
            for i = 1:obj.Ds
                plot(As, 1:obj.N, obj.x_k(i,:), '-', 1:obj.N, obj.x_h_k(i,:), '--');
            end
        end
        
    end
    
end

