classdef ExtendedKalmanFilter < handle
    %EXTENDED_KALMAN_FILTER An extended Kalman filter (EKF).
    
    % Copyright (C) 2012 Jean-Pierre de la Croix
    % see the LICENSE file included with this software
    
    properties
        sys         % stochastic system
        
        Q_k         % state noise covariance matrix at step k
        R_k         % measurement noise covariance matrix at step k
        P_k         % error covariance matrix at step k
        
        Ds          % dimension of state space
        Dm          % dimension of measurement space
        
        N           % total # of steps
    end
    
    methods
        function obj = ExtendedKalmanFilter(sys, P_0, N)
            % 0. Validate input parameters.
            assert(isa(sys, 'mcodekit.system.StochasticSystem'), 'sys has to be a stochastic system');
            obj.sys = sys;
            
            assert(round(N)>=1, 'N has to be at least 1');
            obj.N = round(N);
            
            assert((size(P_0,1)==sys.Ds)&&(size(P_0,2)==sys.Ds), 'P_0 has the wrong dimensions');
            
            obj.Ds = sys.Ds;
            obj.Dm = sys.Dm;
            
            % 1. Initialize filter.
            k = 1;
            
            obj.P_k = zeros(obj.Ds, obj.Ds, N);
            obj.P_k(:,:,k) = P_0;
            
            obj.Q_k = sys.sigma_w^2*eye(obj.Ds);
            obj.R_k = sys.sigma_n^2*eye(obj.Dm);            
        end
        
        % 2. Apply the filter.
        function [x_h_k, z_h_k] = apply_filter(obj, x_h_k_1, z_k, k)
            
            % 2.1 Step 1: Predicted state estimate
            x_h_k_k_1 = obj.sys.f_state(x_h_k_1, 0, k);
            
            % 2.2 Step 2: Predicted covariance estimate
            F_k_1 = obj.sys.jacobian_f_state_x(x_h_k_1, k);
            P_k_1 = F_k_1*obj.P_k(k-1)*F_k_1'+obj.Q_k;
            
            % 2.3 Step 3: Kalman gain
            H_k = obj.sys.jacobian_h_meas_x(x_h_k_k_1, k);
            K_k = P_k_1*H_k'*(H_k*P_k_1*H_k'+obj.R_k)^(-1);
            
            % 2.4 Step 4: Updated state estimate
            x_h_k = x_h_k_k_1+K_k*(z_k-obj.sys.h_meas(x_h_k_k_1, 0, k));
            
            % 2.5 Step 5: Updated covariance estimate
            obj.P_k(k) = (1-K_k*H_k)*P_k_1;
            
            % 2.6 Compute filtered measurement.
            z_h_k = obj.sys.h_meas(x_h_k, 0, k);
        end  
    end
    
end

