using System.IO;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace com.binouze.Editor
{
    public class SWVPostBuildScript : MonoBehaviour, IPostprocessBuildWithReport
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
            
            // -- ADD USE WEBKIT FOR WEBVIEWS

            var pchloc = report.summary.outputPath + "/Classes/Prefix.pch";
            var pch    = File.ReadAllText( pchloc );
            if( !pch.Contains( "#import <WebKit/WebKit.h>" ) )
            {
                pch = pch.Replace( "#import <UIKit/UIKit.h>", "#import <UIKit/UIKit.h>\n\t#import <WebKit/WebKit.h>" );
                File.WriteAllText( pchloc, pch );
            }
            
            #endif
        }
    }
}