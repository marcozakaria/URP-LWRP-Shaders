#if UNITY_EDITOR

using System.IO;
using UnityEditor.Recorder;
using UnityEditor.Recorder.Input;

namespace UnityEngine.Recorder.Examples
{
    /// <summary>
    /// This example shows how to setup a recording session via script.
    /// To use this example. Simply add the CaptureScreenShotExample component to a GameObject.
    /// 
    /// Entering playmode will display a "Capture ScreenShot" button.
    /// 
    /// Recorded images are saved in [Project Folder]/SampleRecordings
    /// </summary>
    public class CaptureScreenShotExample : MonoBehaviour
    {
       RecorderController m_RecorderController;
             
       void OnEnable()
       {
           var controllerSettings = ScriptableObject.CreateInstance<RecorderControllerSettings>();
           m_RecorderController = new RecorderController(controllerSettings);
 
           var mediaOutputFolder = Path.Combine(Application.dataPath, "..", "SampleRecordings");

           // Image
           var imageRecorder = ScriptableObject.CreateInstance<ImageRecorderSettings>();
           imageRecorder.name = "My Image Recorder";
           imageRecorder.Enabled = true;
           imageRecorder.OutputFormat = ImageRecorderSettings.ImageRecorderOutputFormat.PNG;
           imageRecorder.CaptureAlpha = false;
           
           imageRecorder.OutputFile = Path.Combine(mediaOutputFolder, "image_" + DefaultWildcard.Take);
    
           imageRecorder.imageInputSettings = new GameViewInputSettings
           {
               OutputWidth = 3840,
               OutputHeight = 2160,
           };
    
           // Setup Recording
           controllerSettings.AddRecorderSettings(imageRecorder);
           controllerSettings.SetRecordModeToSingleFrame(0);
       }
    
        void OnGUI()
        {
            if (GUI.Button(new Rect(10, 10, 150, 50), "Capture ScreenShot"))
            {
                m_RecorderController.StartRecording();
            }
        }
    }
 }
    
 #endif
