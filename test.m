% filter = IMU_ErrorStateKalmanFilter('processed_data.mat');
q1 = Quaternion([1;-1;-1.1;1])
q2 = Quaternion([2;2;2;2])
qans = q2*inv(q2)