#if UNITY_EDITOR

using System.IO;
using UnityEditor;
using UnityEditor.Recorder;
using UnityEditor.Recorder.Input;

namespace UnityEngine.Recorder.Examples
{
    /// <summary>
    /// This example shows how to setup a recording session via script.
    /// To use this example. Simply add the MultipleRecordingsExample component to a GameObject.
    /// 
    /// Entering playmode will start the recording.
    /// The recording will automatically stops when exiting playmode (or when the component is disabled).
    /// 
    /// Recording outputs are saved in [Project Folder]/SampleRecordings (except for the recorded animation which is saved in Assets/SampleRecordings).  
    /// </summary>
    public class MultipleRecordingsExample : MonoBehaviour
    {
       RecorderController m_RecorderController;
    
       void OnEnable()
       {
           var controllerSettings = ScriptableObject.CreateInstance<RecorderControllerSettings>();
           m_RecorderController = new RecorderController(controllerSettings);

           var mediaOutputFolder = Path.Combine(Application.dataPath, "..", "SampleRecordings");
           // animation output is an asset that must be created in Assets folder
           var animationOutputFolder = Path.Combine(Application.dataPath, "SampleRecordings");

           // Video
           var videoRecorder = ScriptableObject.CreateInstance<MovieRecorderSettings>();
           videoRecorder.name = "My Video Recorder";
           videoRecorder.enabled = true;
    
           videoRecorder.outputFormat = VideoRecorderOutputFormat.MP4;
           videoRecorder.videoBitRateMode = VideoBitrateMode.Low;
    
           videoRecorder.imageInputSettings = new GameViewInputSettings
           {
               outputWidth = 1920,
               outputHeight = 1080
           };
    
           videoRecorder.audioInputSettings.preserveAudio = true;
    
           videoRecorder.outputFile = Path.Combine(mediaOutputFolder, "video_v" + DefaultWildcard.Take);
    
           // Animation
           var animationRecorder = ScriptableObject.CreateInstance<AnimationRecorderSettings>();
           animationRecorder.name = "My Animation Recorder";
           animationRecorder.enabled = true;
    
           var sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
    
           animationRecorder.animationInputSettings = new AnimationInputSettings
           {
               gameObject = sphere, 
               recursive = true,
           };
           
           animationRecorder.animationInputSettings.AddComponentToRecord(typeof(Transform));
           
           animationRecorder.outputFile = Path.Combine(animationOutputFolder, "anim_" + DefaultWildcard.GeneratePattern("GameObject") + "_v" + DefaultWildcard.Take);
    
           // Image Sequence
           var imageRecorder = ScriptableObject.CreateInstance<ImageRecorderSettings>();
           imageRecorder.name = "My Image Recorder";
           imageRecorder.enabled = true;
    
           imageRecorder.outputFormat = ImageRecorderOutputFormat.PNG;
           imageRecorder.captureAlpha = true;

           imageRecorder.outputFile = Path.Combine(mediaOutputFolder, "_png", "image_v" + DefaultWildcard.Take + "." + DefaultWildcard.Frame);

           imageRecorder.imageInputSettings = new CameraInputSettings
           {
               source = ImageSource.MainCamera,
               outputWidth = 1920,
               outputHeight = 1080,
               captureUI = true
           };
    
           // Setup Recording
           controllerSettings.AddRecorderSettings(videoRecorder);
           controllerSettings.AddRecorderSettings(animationRecorder);
           controllerSettings.AddRecorderSettings(imageRecorder);
    
           controllerSettings.SetRecordModeToManual();
           controllerSettings.frameRate = 60.0f;
    
           Options.verboseMode = false;
           m_RecorderController.StartRecording();
       }
    
       void OnDisable()
       {
           m_RecorderController.StopRecording();
       }
    }
 }
    
 #endif
