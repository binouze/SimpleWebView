﻿using System;
using JetBrains.Annotations;
using UnityEngine;

#if UNITY_IOS
using System.Runtime.InteropServices;
#endif

namespace com.binouze
{
    public class SimpleWebView : MonoBehaviour
    {
        private static  Action         PopupClosed;
        private static  Action         PopupClosedWait;
        private static  Action<string> PopupData;

        private static bool   LogEnabled;
        private static bool   HasWebView;
        private static bool   HasWebViewFocus;
        
        #if UNITY_IOS
        [DllImport( "__Internal")]
        private static extern void WK_openFrame(string url);
        [DllImport( "__Internal")]
        private static extern void WK_closeFrame();
        [DllImport( "__Internal")]
        private static extern bool WK_CanOpenURL(string url);
        #elif UNITY_ANDROID
        private const string AndroidClass = "com.binouze.SimpleWebView";
        #endif
        
        private static void Log( string str )
        {
            if( LogEnabled )
                Debug.Log( $"[SimpleWebView] {str}" );
        }

        /// <summary>
        /// set it to true to enable plugin logs
        /// </summary>
        /// <param name="enabled"></param>
        [UsedImplicitly]
        public static void SetDebugLogging( bool enabled )
        {
            LogEnabled = enabled;
        }

        /// <summary>
        /// Open a webview
        /// </summary>
        /// <param name="url"></param>
        [UsedImplicitly]
        public static void OpenWebView( string url )
        {
            OpenWebView( url, null, null );
        }
        
        /// <summary>
        /// Open a webview
        /// </summary>
        /// <param name="url"></param>
        /// <param name="OnClosed"></param>
        [UsedImplicitly]
        public static void OpenWebView( string url, Action OnClosed )
        {
            OpenWebView( url, OnClosed, null );
        }
        
        /// <summary>
        /// Open a webview
        /// </summary>
        /// <param name="url"></param>
        /// <param name="OnClosedWithDatas"></param>
        [UsedImplicitly]
        public static void OpenWebView( string url, Action<string> OnClosedWithDatas )
        {
            OpenWebView( url, null, OnClosedWithDatas );
        }
        
        
        private static void OpenWebView( string url, Action OnClosed, Action<string> OnData )
        {
            Log( $"OpenWebView {url}" );
            
            // be sure to have an instance
            SetInstance();
            
            // close any previous webview
            if( HasWebView )
                CloseWebView();

            // init variables
            PopupClosed     = null;
            PopupClosedWait = OnClosed;
            PopupData       = OnData;
            HasWebView      = true;
            HasWebViewFocus = false;
            
            // show the webview
            #if UNITY_ANDROID && !UNITY_EDITOR
            using( var cls = new AndroidJavaClass( AndroidClass ) ) 
            {
                var ok = cls.CallStatic<bool>( "OpenWebView", url );  
                if( !ok )
                {
                    Log( $"CutomTab not available, opening external browser" );
                    Application.OpenURL( url );
                }
            }	
            #elif UNITY_IOS && !UNITY_EDITOR
            _instance.OnApplicationFocus( false );
            WK_openFrame(url);
            #endif
        }

        [UsedImplicitly]
        public static void CloseWebView()
        {
            Log( $"CloseWebView HasWebView:{HasWebView} HasWebViewFocus:{HasWebViewFocus}" );
            
            PopupClosed     = null;
            PopupClosedWait = null;
            PopupData       = null;

            #if UNITY_ANDROID && !UNITY_EDITOR
            if( string.isNullOrEmpty(URLScheme) )
                return;
            
            using( var cls = new AndroidJavaClass( AndroidClass ) ) 
            {
                cls.CallStatic( "CloseWebView" ); 
            }	
            #elif UNITY_IOS && !UNITY_EDITOR
            WK_closeFrame();
            #endif
        }

        [UsedImplicitly]
        public static void LaunchAppAndroid( string packageName, string referrer )
        {
            Log( $"LaunchApp {packageName} {referrer}" );
            
            SetInstance();
            #if UNITY_ANDROID && !UNITY_EDITOR
            using( var cls = new AndroidJavaClass( AndroidClass ) ) 
            {
                cls.CallStatic( "LaunchApp", packageName, referrer );  
            }
            #endif
        }
        
        [UsedImplicitly]
        public static void LaunchAppIOS( string urlscheme, string datas, string storeUrl )
        {
            Log( $"LaunchAppIOS {urlscheme} {datas} {storeUrl}" );
            
            SetInstance();
            
            #if UNITY_IOS && !UNITY_EDITOR
            if( WK_CanOpenURL( urlscheme ) )
            {
                Application.OpenURL( urlscheme+datas );
            }
            else
            {
                Application.OpenURL( storeUrl );
            }
            #endif
        }
        
        [UsedImplicitly]
        public static bool CanOpenURL( string urlscheme )
        {
            SetInstance();
            
            #if UNITY_IOS && !UNITY_EDITOR
            var ok = WK_CanOpenURL( urlscheme );
            Log( $"CanOpenURL {urlscheme} -> {ok}" );
            return ok;
            #endif
            Log( $"CanOpenURL {urlscheme} -> NON" );
            return false;
        }
        
        [UsedImplicitly]
        public void OnPopupClosed()
        {
            Log( "OnPopupClosed" );
            OnApplicationFocus( true );
        }

        [UsedImplicitly]
        public void OnPopupData(string str)
        {
            Log( $"OnPopupData {str}" );
            var ondata = PopupData;
            OnPopupClosed();
            
            #if UNITY_IOS && !UNITY_EDITOR
            WK_closeFrame();
            #endif
            
            ondata?.Invoke(str);
        }

        private void OnApplicationFocus( bool hasFocus )
        {
            Log( $"OnApplicationFocus hasFocus:{hasFocus} HasWebView:{HasWebView} HasWebViewFocus:{HasWebViewFocus}" );
            if( !hasFocus && HasWebView )
            {
                Log( "Start focus webview => OPEN" );
                
                HasWebViewFocus = true;
                PopupClosed     = PopupClosedWait;
                PopupClosedWait = null;
            }
            else if( hasFocus && HasWebViewFocus )
            {
                Log( "Stop focus webview => CLOSE" );
                
                HasWebView      = false;
                HasWebViewFocus = false;
                
                PopupClosed?.Invoke();
                PopupClosed = null;
                PopupData   = null;
            }
        }

        private static SimpleWebView _instance;
        private static void SetInstance() 
        {
            if( _instance == null ) 
            {
                _instance = (SimpleWebView)FindObjectOfType( typeof(SimpleWebView) );
                if( _instance == null ) 
                {
                    const string goName = "_Extern_WebViewLight";          

                    var go = GameObject.Find( goName );
                    if( go == null ) 
                    {
                        go = new GameObject {name = goName};
                        DontDestroyOnLoad( go );
                    }
                    _instance = go.AddComponent<SimpleWebView>();
                    Application.deepLinkActivated += _instance.OnPopupData;
                }
            }
        }
    }
}