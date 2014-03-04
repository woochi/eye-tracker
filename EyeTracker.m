classdef EyeTracker < Singleton

    properties % Public Access
        connected;
        pCalibrationData;
        pSystemInfoData;
        pAccuracyData;        
    end
   
    methods(Access=private)
        % Guard the constructor against external invocation.  We only want
        % to allow a single instance of this class.  See description in
        % Singleton superclass.
        function newObj = EyeTracker()
            % Initialise your custom properties.         
            newObj.connected = 0;
            newObj.pCalibrationData = [];
            newObj.pSystemInfoData = [];
            newObj.pAccuracyData = [];
            % Load the SMI library
            loadlibrary('iViewXAPI.dll', 'iViewXAPI.h');
        end
    end
   
    methods(Static)
    % Concrete implementation.  See Singleton superclass.
        function obj = instance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = EyeTracker();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
    end
   
   %*** Define your own methods for SingletonImpl.
    methods % Public Access        
        function initializeTracker(obj)
            % load the iViewX API library
            %while (connected~=1 || calibResult~=1)

            [pSystemInfoData, pSampleData, pEventData, obj.pAccuracyData, CalibrationData] = InitiViewXAPI();

            CalibrationData.method = int32(9);
            CalibrationData.visualization = int32(1);
            CalibrationData.displayDevice = int32(1);
            CalibrationData.speed = int32(0);
            CalibrationData.autoAccept = int32(1);
            CalibrationData.foregroundBrightness = int32(250);
            CalibrationData.backgroundBrightness = int32(230);
            CalibrationData.targetShape = int32(2);
            CalibrationData.targetSize = int32(20);
            CalibrationData.targetFilename = int8('');
            obj.pCalibrationData = libpointer('CalibrationStruct', CalibrationData);

            disp('Define Logger')
            calllib('iViewXAPI', 'iV_SetLogger', int32(1), 'iViewXSDK_Matlab_Slideshow_Demo.txt');
        end
        
        function connect(obj)
            disp('Connect to iViewX')
            ret = calllib('iViewXAPI', 'iV_Connect', '192.168.1.3', int32(4444), '192.168.1.2', int32(5555));
            switch ret
                case 1
                    obj.connected = 1;
                case 104
                     msgbox('Could not establish connection. Check if Eye Tracker is running', 'Connection Error', 'modal');
                case 105
                     msgbox('Could not establish connection. Check the communication Ports', 'Connection Error', 'modal');
                case 123
                     msgbox('Could not establish connection. Another Process is blocking the communication Ports', 'Connection Error', 'modal');
                case 200
                     msgbox('Could not establish connection. Check if Eye Tracker is installed and running', 'Connection Error', 'modal');
                otherwise
                     msgbox('Could not establish connection', 'Connection Error', 'modal');
            end


            if obj.connected
                disp('Get System Info Data')
                calllib('iViewXAPI', 'iV_GetSystemInfo', obj.pSystemInfoData)
                get(obj.pSystemInfoData, 'Value')
            end
            
        end
        
        function calibrate(obj)
            disp('Calibrate iViewX')
            calllib('iViewXAPI', 'iV_SetupCalibration', obj.pCalibrationData)
            calllib('iViewXAPI', 'iV_Calibrate')
            disp('Validate Calibration')
            calllib('iViewXAPI', 'iV_Validate')
            disp('Validation Result:')
            calllib('iViewXAPI', 'iV_GetAccuracy', obj.pAccuracyData, int32(0))
            get(obj.pAccuracyData,'Value')       
        end
        
        function startRecording(obj)
            calllib('iViewXAPI', 'iV_StartRecording');
        end        
        
        function setMarker(obj, marker)
            %send marker to iviewx 
            calllib('iViewXAPI', 'iV_SendImageMessage', marker)
        end
        
        function saveData(obj, filename)
            calllib('iViewXAPI', 'iV_SaveData', formatString(256, int8(filename)), formatString(64, int8('asd')), formatString(64, int8('asd')), int8(1))
        end
        
        function stopRecording(obj)
            calllib('iViewXAPI', 'iV_StopRecording')
        end
        
        function disconnect(obj)
            calllib('iViewXAPI', 'iV_Disconnect');
        end


    end

   
    
end

