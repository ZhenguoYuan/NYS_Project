function QA_Struct=QualityFlags(AOT_QA)

AOT_QA=AOT_QA'; %It is important!! Because the output of dec2bin function will transform the array!!!
AOT_QA_BI=dec2bin(AOT_QA,16);
QA_Cloud_Mask=AOT_QA_BI(:,14:16);
QA_Land_Water_Snowice_Mask=AOT_QA_BI(:,12:13);
QA_Adjacency_Mask=AOT_QA_BI(:,9:11);
QA_Cloud_Test_Path=AOT_QA_BI(:,5:8);
QA_Glint_Mask=AOT_QA_BI(:,4);
QA_Aerosol_Model=AOT_QA_BI(:,2:3);
QA_Quality_Flag=AOT_QA_BI(:,1);

QA_Struct=struct('QA_Cloud_Mask',QA_Cloud_Mask,...
    'QA_Land_Water_Snowice_Mask',QA_Land_Water_Snowice_Mask,...
    'QA_Adjacency_Mask',QA_Adjacency_Mask,...
    'QA_Cloud_Test_Path',QA_Cloud_Test_Path,...
    'QA_Glint_Mask',QA_Glint_Mask,...
    'QA_Aerosol_Model',QA_Aerosol_Model,...
    'QA_Quality_Flag',QA_Quality_Flag);

end