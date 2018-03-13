function [sateAOT047,sateAOT055]=filterAOT(sateAOT047,sateAOT055,QA_Struct,RelAZ_1km,do_filter)

if (nargin < 5)
    do_filter = true;
end

if do_filter % May or may not do the filtering
    [rows,cols]=size(sateAOT047);
    for i=1:rows
        for j=1:cols
            if ~isnan(sateAOT047(i,j)) || ~isnan(sateAOT055(i,j))
                
                LWSM_flag=QA_Struct.QA_Land_Water_Snowice_Mask((i-1)*cols+j,:); % QA: Land_Water_Snowice_Mask
                CM_flag=QA_Struct.QA_Cloud_Mask((i-1)*cols+j,:); % QA: Cloud_Mask
                AM_flag=QA_Struct.QA_Adjacency_Mask((i-1)*cols+j,:); % QA: Adjacency Mask
                GM_flag=QA_Struct.QA_Glint_Mask((i-1)*cols+j,:); % QA: Glint Mask
                AQA_flag=QA_Struct.QA_Quality_Flag((i-1)*cols+j,:); % QA: AOT Quality Flag
                
                if ~strcmp(LWSM_flag,'00')... % Keep pixels without water, snow, and ice.
                        || strcmp(AQA_flag,'1') % Remove pixels with which AOT quality flags equal 1 (possible cloud)
                    %{
                    || ~strcmp(CM_flag,'001')... % Keep clear pixels without cloud
                    || strcmp(AM_flag,'011')... % Remove single cloudy pixels
                    || ~strcmp(GM_flag,'0')... % Keep pixels with glint = 0
                    || RelAZ_1km(i,j)>90 % Keep the forward scattering (FS) directions
                        %}
                        sateAOT047(i,j)=NaN;
                        sateAOT055(i,j)=NaN;
                end
                
            end
        end
    end
end

end