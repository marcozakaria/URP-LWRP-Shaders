
 namespace UnityEditor.Recorder.Examples
 {
     /// <summary>
     /// This example shows how to add "Start Recording" and "Stop Recording" menu items that can then be used to start/stop the
     /// Recorders defined in the Recorder window.
     ///
     /// </summary>
     /// <exclude/>
     public static class RecorderEditorExample
     {
         [MenuItem(RecorderWindow.MenuRoot + "Examples/Start Recording", false, RecorderWindow.MenuRootIndex + 100)]
         static void StartRecording()
         {
             var recorderWindow = EditorWindow.GetWindow<RecorderWindow>();
             recorderWindow.StartRecording();
         }

         [MenuItem(RecorderWindow.MenuRoot + "Examples/Stop Recording", false, RecorderWindow.MenuRootIndex + 100)]
         static void StopRecording()
         {
             var recorderWindow = EditorWindow.GetWindow<RecorderWindow>();
             recorderWindow.StopRecording();
         }
     }
 }
