using System.IO;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;
#if UNITY_IOS
using UnityEditor.iOS.Xcode;
#endif

namespace com.binouze.Editor
{
    public class SWVPostBuildScript : IPostprocessBuildWithReport
    {
        /// <summary>
        ///   <para>Returns the relative callback order for callbacks.  Callbacks with lower values are called before ones with higher values.</para>
        /// </summary>
        public int callbackOrder { get; } = 1;

        /// <summary>
        ///   <para>Implement this function to receive a callback after the build is complete.</para>
        /// </summary>
        /// <param name="report">A BuildReport containing information about the build, such as the target platform and output path.</param>
        public void OnPostprocessBuild( BuildReport report )
        {
            #if UNITY_IOS
            if( report.summary.platform != BuildTarget.iOS )
                return;
            
            // -- ADD USE WEBKIT FOR WEBVIEWS

            var pchloc = report.summary.outputPath + "/Classes/Prefix.pch";
            var pch    = File.ReadAllText( pchloc );
            if( !pch.Contains( "#import <WebKit/WebKit.h>" ) )
            {
                pch = pch.Replace( "#import <UIKit/UIKit.h>", "#import <UIKit/UIKit.h>\n\t#import <WebKit/WebKit.h>" );
                File.WriteAllText( pchloc, pch );
            }
            
            // -- SOURCES SWIFT COMPILEES DANS UNITYFRAMEWORK
            
            // Unity copie les .swift du plugin dans la cible UnityFramework. Il leur faut une version de
            // Swift, et un module defini pour que Xcode genere UnityFramework-Swift.h, importe par swkwv.mm
            var projPath = PBXProject.GetPBXProjectPath( report.summary.outputPath );
            var proj     = new PBXProject();
            proj.ReadFromFile( projPath );
            
            var cible = proj.GetUnityFrameworkTargetGuid();
            proj.SetBuildProperty( cible, "SWIFT_VERSION",  "5.0" );
            proj.SetBuildProperty( cible, "DEFINES_MODULE", "YES" );
            
            proj.WriteToFile( projPath );
            
            #endif
        }
    }
}