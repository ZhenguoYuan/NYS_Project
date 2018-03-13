function saveCSV(AOT047,AOT055,AOT_Uncertainty,AOT_QA,Lat,Lon,LatRange,LonRange,QA_Struct,Year,Doy,Hour,Minute,outputpath,dataName)

rows=size(AOT047,1);
cols=size(AOT047,2);

fID=fopen([outputpath,dataName(1:28),'.csv'],'w');

fprintf(fID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','Year','Doy','Hour','Minute',...
    'Latitude','Longitude','AOT_047','AOT_055','AOT_Uncertainty','AOT_QA','QA_cloudmask',...
    'QA_landmask','QA_adjmask','QA_cloudtest','QA_glintmask','QA_aerosolmodel','QA_aotqualityflag');

for i=1:rows
    for j=1:cols
        if Lat(i,j)>=LatRange(1) && Lat(i,j)<=LatRange(2) && Lon(i,j)>=LonRange(1) && Lon(i,j)<=LonRange(2) %Lima area
            fprintf(fID,'%d,%d,%d,%d,%f,%f,%f,%f,%f,''%s,''%s,''%s,''%s,''%s,''%s,''%s,''%s\n',Year,Doy,Hour,Minute,...
                Lat(i,j),Lon(i,j),AOT047(i,j),AOT055(i,j),AOT_Uncertainty(i,j),dec2bin(AOT_QA(i,j),16),...
                QA_Struct.QA_Cloud_Mask((i-1)*cols+j,:),QA_Struct.QA_Land_Water_Snowice_Mask((i-1)*cols+j,:),...
                QA_Struct.QA_Adjacency_Mask((i-1)*cols+j,:),QA_Struct.QA_Cloud_Test_Path((i-1)*cols+j,:),...
                QA_Struct.QA_Glint_Mask((i-1)*cols+j,:),QA_Struct.QA_Aerosol_Model((i-1)*cols+j,:),...
                QA_Struct.QA_Quality_Flag((i-1)*cols+j,:));
        end
    end
end

fclose(fID);

end