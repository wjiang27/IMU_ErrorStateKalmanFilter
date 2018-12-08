classdef Quaternion
    %QUATERNION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        q % a quaternion desribed in a [4x1] vector
        % the first component is the scalar part of the quarternion
        % the remaining components are its vector part
    end
    
    methods
        %% Quaternion Constructor
        function obj = Quaternion(varargin)
            if nargin == 0
                obj.q = [0;0;0;0];
            elseif nargin == 1 && isvector(varargin{1}) && size(varargin{1},1)==4
                %build quaternion from a [4x1] Vector
                obj.q = varargin{1};
            elseif nargin == 1 && isa(varargin{1},'Quaternion')
                obj = Quaternion(varargin{1}.q);
            %Build a Quaternion from the rotation angles and rotation axis.    
            elseif nargin == 2 && isvector(varargin{2}) && size(varargin{2},1)==3 ...
                    && isscalar(varargin{1})
                if(abs(norm(varargin{2})-1)>1e-8)
                    error ('Quaternion Constructor Error, Rotation Axis Norm Not Equal to 1')
                end
                obj = Quaternion([cos(varargin{1}/2);sin(varargin{1}/2)*varargin{2}]);
            %Build a Quaternion from the lie algebra so(3) ([3x1] Vector) Jose Page 47
            elseif nargin == 1 && isvector(varargin{1}) && size(varargin{1},1)==3
                v = varargin{1};
                obj = Quaternion([cos(norm(v)/2);v/norm(v)*sin(norm(v)/2)]);
            elseif nargin == 2 && isvector(varargin{1}) && size(varargin{1},1)==3 && strcmp(varargin{2},'euler2Quaternion')
                %build quaternion from XYZ Euler Angles
                qx = Quaternion(varargin{1}(1),[1;0;0]);
                qy = Quaternion(varargin{1}(2),[0;1;0]);
                qz = Quaternion(varargin{1}(3),[0;0;1]);
                obj = qz*(qy*qx);
            else
                error ('invalid argument for Quaternion constructor')
            end
        end% End of Constrcutor
        %% Quaternion Functions
       
        %normalize a quaternion
        function q = normalize(obj)
            q = Quaternion(obj.q/norm(obj.q));
        end
        %left product Matrix
        function matrix_ql = leftProductMatrix(obj)
            matrix_ql = zeros(4,4);
            matrix_ql(2:4,2:4)=v2s(obj.q(2:4));
            matrix_ql(1,2:4)=-obj.q(2:4).';
            matrix_ql(2:4,1)=obj.q(2:4);
            matrix_ql = matrix_ql + obj.q(1)*eye(4);
        end
        %right product Matrix
        function matrix_qr = rightProductMatrix(obj)
            matrix_qr = zeros(4,4);
            matrix_qr(2:4,2:4)=-v2s(obj.q(2:4));
            matrix_qr(1,2:4)=-obj.q(2:4).';
            matrix_qr(2:4,1)=obj.q(2:4);
            matrix_qr= matrix_qr + obj.q(1)*eye(4);
        end
        %norm
        function n = norm(obj)
            n = sqrt(obj.q.'*obj.q);
        end
        %inverse
        function qinv = inv(obj)
            qinv = (1/norm(obj))^2*obj';
        end
        %compute corresponding XYZ Euler angles
        function eulerAngles = toEulerAngles(obj)
            qvector = obj.q;
            rad2deg=180/pi;
            T=[ 1 - 2 * (qvector(4) *qvector(4) + qvector(3) * qvector(3))  2 * (qvector(2) * qvector(3) +qvector(1) * qvector(4))         2 * (qvector(2) * qvector(4)-qvector(1) * qvector(3));
                2 * (qvector(2) * qvector(3)-qvector(1) * qvector(4))       1 - 2 * (qvector(4) *qvector(4) + qvector(2) * qvector(2))     2 * (qvector(3) * qvector(4)+qvector(1) * qvector(2));
                2 * (qvector(2) * qvector(4) +qvector(1) * qvector(3))      2 * (qvector(3) * qvector(4)-qvector(1) * qvector(2))          1 - 2 * (qvector(2) *qvector(2) + qvector(3) * qvector(3))];%cnb
            roll  = atan2(T(2,3),T(3,3))*rad2deg;
            pitch = asin(-T(1,3))*rad2deg;
            yaw   = atan2(T(1,2),T(1,1))*rad2deg;
            eulerAngles = [roll;pitch;yaw];
        end
        
        %% Operators Overloading
        
        %conjugation
        function q = ctranspose(obj)
            q = Quaternion([obj.q(1);-obj.q(2:4)]);
        end
        
        %mtimes
        function qans = mtimes(x1,x2)
            if isa(x1,'Quaternion') && isa(x2,'Quaternion')
                scalar = x1.q(1)*x2.q(1) - x1.q(2:4).'*x2.q(2:4);
                vector = x1.q(1)*x2.q(2:4)+x2.q(1)*x1.q(2:4)+cross(x1.q(2:4),x2.q(2:4));
                qans = Quaternion([scalar;vector]);
            elseif isscalar(x1) && isa(x2,'Quaternion')
                qans = Quaternion(x1*x2.q);
            elseif isscalar(x2) && isa(x1,'Quaternion')
                qans = Quaternion(x2*x1.q);
            else
                error('mtimes (*) operator error')
            end
        end
        
        function qans = plus(x1,x2)
            if isa(x1,'Quaternion') && isa(x2,'Quaternion')
                qans = Quaternion(x1.q+x2.q);
            else
                error('plus (+) operator error')
            end
        end
        
        function qans = minus(x1,x2)
            if isa(x1,'Quaternion') && isa(x2,'Quaternion')
                qans = Quaternion(x1.q-x2.q);
            else
                error('minus (-) operator error')
            end
        end
    end
end

