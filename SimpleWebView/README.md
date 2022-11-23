# SimpleWebView

Simple WebView to use in Unity projects on iOS and Android

- on Android the plugin uses the CustomTabsIntent, as it is the most simple implementation of webviews for Android.
- on iOS the plugin uses a modified version of [Baris Atamer's SmartWKWebView](https://github.com/barisatamer/SmartWKWebView).

## Installation

Choose your favourite method:

- **Plain install**
    - Clone or [download](https://github.com/binouze/SimpleWebView/archive/refs/heads/master.zip) 
this repository and put it in the `Assets/Plugins` folder of your project.
- **Unity Package Manager (Manual)**:
    - Add the following line to *Packages/manifest.json*:
    - `"com.binouze.simplewebview": "https://github.com/binouze/SimpleWebView.git"`
- **Unity Package Manager (Auto)**
    - in the package manager, click on the + 
    - select `add package from GIT url`
    - paste the following url: `"https://github.com/binouze/SimpleWebView.git"`


## How to use

```csharp
    private void OpenMyWebContent()
    {
        // just open a webview with an url
        SimpleWebView.OpenWebView( url );
        
        // opens an url and know when is it closed
        SimpleWebView.OpenWebView( url, () => {
            Debug.Log("my webview has been closed"); 
        });
        
        // opens an url and receive datas from it when it closes
        // to send datas to unity from your webview, use your app urlscheme from the webpage,
        // this will close the webview and send the datas
        SimpleWebView.OpenWebView( url, datas => {
            Debug.Log($"my webview has been closed with datas {datas}"); 
        });
    }
    
    // Optionnaly, this plugin can open apps if installed on the device
    // if not installed, it will open the store to download it
    private void OpenMyApp()
    {
        var datas = $"utm_source={utm_source}&utm_medium={utm_medium}&utm_campaign={utm_campaign}";
        
        #if UNITY_ANDROID
            // for android it uses package name,
            // additionnal datas can be sent as referrer datas and retrived after app install
            var referrerData = Uri.EscapeDataString( datas );
            SimpleWebView.LaunchAppAndroid("com.binouze.testapp", referrerData);
        #elif UNITY_IOS
            // for ios it uses url scheme, and fallback to store url
            SimpleWebView.LaunchAppIOS(
                "test://", 
                $"test/?{datas}",
                "https://itunes.apple.com/us/app/xxxxxxxxx/idXXXXXXXXX?mt=8");
        #endif
    }
    
    // If needed, you can force close the webview
    private void CloseWebview()
    {
        SimpleWebView.CloseWebView();
    }
    
```