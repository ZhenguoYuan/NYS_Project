function data=readHDF(sdID,datasetName,scale_flag)

import matlab.io.hdf4.*

idx=sd.nameToIndex(sdID,datasetName);
sdsID=sd.select(sdID,idx);
data=sd.readData(sdsID);

if scale_flag==1 % do scale and offset process
    
    idx=sd.findAttr(sdsID,'scale_factor'); %scale_factor
    data_scale=sd.readAttr(sdsID,idx);
    idx=sd.findAttr(sdsID,'add_offset'); %add_offset
    data_offset=sd.readAttr(sdsID,idx);
    idx=sd.findAttr(sdsID,'_FillValue'); %_FillValue
    data_null=sd.readAttr(sdsID,idx);
    
    data=double(data);
    data(data==data_null)=NaN;
    data=double(data)*data_scale+data_offset;
    
end



%Close dataset
sd.endAccess(sdsID);

end