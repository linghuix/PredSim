% Return -180 - +180 degree.
% sign   postive - from vector_1 to vector_2
% 2D
function Angle = get_angle(vector_1, vector_2)

    % angle < 90 or > -90
    check_vector = vector_2./norm(vector_2) - vector_1./norm(vector_1);
    
    flag_s90 = norm(check_vector)<=sqrt(2);
    flag_g90 = norm(check_vector)>sqrt(2);
%     vector_1_s90 = vector_1(flag_s90);     % smaller than 90 degree
%     vector_2_s90 = vector_2(flag_s90);
%     vector_1_g90 = vector_1(norm(check_vector)>sqrt(2)/2);      % greater than 90 degree
%     vector_2_g90 = vector_2(norm(check_vector)>sqrt(2)/2);
    
    if (flag_s90)
        cos_d_s90 = dot(vector_1, vector_2) ./ norm(vector_2) ./ norm(vector_1);
        Angle_s90 = acosd(cos_d_s90);
        % vector 2 is on the left to vector 1
        if (check_vector(1)<0)
            Angle_s90= -Angle_s90;
        end
        Angle = Angle_s90;
    
    
    % angle > 90 or < -90
    elseif (flag_g90)
        cos_d_g90 = dot(vector_1, vector_2) ./ norm(vector_2) ./ norm(vector_1);
        Angle_g90 = acosd(cos_d_g90);
        % vector 2 is on the left to vector 1
        if (check_vector(1)<0)
            Angle_g90= -Angle_g90;
        end
        Angle = Angle_g90;
    end

end