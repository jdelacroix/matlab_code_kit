classdef ParticleFilter < handle
    %PARTICLE_FILTER A particle filter
    % inspired by http://www.mathworks.com/matlabcentral/fileexchange/35468
    
    % Copyright (C) 2012 Jean-Pierre de la Croix
    % see the LICENSE file included with this software
    
    properties
        sys         % stochastic system
        
        Ds          % dimension of the state space
        Dm          % dimension of the measurement space
        
        Ns          % # of particles
        N           % # of steps
        
        ws_k        % weights at step k
        ps_k        % particles at step k
        
        sigma_P     % error variance
    end
    
    methods
        
        function obj = ParticleFilter(sys, sigma_2_P, N, Ns)
           % 0. Validate input parameters.
           assert(isa(sys, 'mcodekit.system.StochasticSystem'), 'sys has to be a stochastic system');
           obj.sys = sys;
           
           assert(round(Ns)>=1, 'Ns has to be at least 1');
           obj.Ns = round(Ns);
           
           assert(round(N)>=1, 'N has to be at least 1');
           obj.N = round(N);
           
           assert(sigma_2_P>=0, 'error variance has to be positive');
           obj.sigma_P = sqrt(sigma_2_P);
           
           obj.Ds = sys.Ds;
           obj.Dm = sys.Dm;
           
           obj.ws_k = zeros(Ns, obj.N);
           obj.ps_k = zeros(obj.Ds, Ns, obj.N);
           
        end
        
        % 1. Apply particle filter
        function [x_h_k, z_h_k] = apply_filter(obj, x_h_k_1, z_k, k)
            
            % 1.0 Initialize filter by generating particles
            ws_k_1 = obj.ws_k(:,k-1);
            if k == 2
                for i = 1:obj.Ns
                   obj.ps_k(:,i,k-1) = obj.sample_p_x_0(); 
                end
                ws_k_1 = repmat(1/obj.Ns, obj.Ns, 1);
            end
            
            % 1.1 Update weights and particles
            ps_k_1 = obj.ps_k(:,:,k-1);
            ps_h_k = zeros(size(ps_k_1));
            ws_h_k = zeros(size(ws_k_1));
            
            for i = 1:obj.Ns
                w_k_1 = obj.sys.sample_state_noise();
                ps_h_k(:,i) = obj.sys.f_state(ps_k_1(:,i), w_k_1, k);
                ws_h_k(i) = ws_k_1(i)*obj.pdf_z_k_x_k(z_k, ps_h_k(:,i), k);
            end
            
            % 1.2 Normalize particles
            ws_h_k = ws_h_k./sum(ws_h_k);
            
            % 1.3 Resample (if bootstrap filter)
            idx = randsample(1:obj.Ns, obj.Ns, true, ws_h_k);
            ps_h_k = ps_h_k(:,idx);
            ws_h_k = repmat(1/obj.Ns, obj.Ns, 1);
            
            % 1.3 Update state estimate
            x_h_k = 0;
            for i= 1:obj.Ns
               x_h_k = x_h_k + ws_h_k(i)*ps_h_k(:,i);
            end
            
            obj.ws_k(:,k) = ws_h_k;
            obj.ps_k(:,:,k) = ps_h_k;
            
            % 1.4 Compute filtered measurement
            z_h_k = obj.sys.h_meas(x_h_k, 0, k);
        end
        
        % 2. Generate pdf for p(z_k|x_k)
        function p_z_k_x_k = pdf_z_k_x_k(obj, z_k, x_k, k)
           p_z_k_x_k = obj.sys.pdf_meas_noise(z_k-obj.sys.h_meas(x_k, 0, k)); 
        end
        
        % 3. Sample from p(x_0)
        function x_0 = sample_p_x_0(obj)
           x_0 = normrnd(0, obj.sigma_P, obj.Ds, 1);
        end
    end
    
end

