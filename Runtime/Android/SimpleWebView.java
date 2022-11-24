package com.binouze;

import android.content.pm.PackageManager;
import 	android.content.pm.PackageManager.NameNotFoundException;
import android.content.Intent;
import android.content.ActivityNotFoundException;
import android.net.Uri;
import com.unity3d.player.UnityPlayer;
import androidx.browser.customtabs.CustomTabsIntent;


public class SimpleWebView
{
    public static boolean OpenWebView( String url )
	{
        CustomTabsIntent customTabsIntent = new CustomTabsIntent.Builder().build();
        customTabsIntent.intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
        
        try
        {
            customTabsIntent.launchUrl( UnityPlayer.currentActivity, Uri.parse(url) );
            return true;
        }
        catch( ActivityNotFoundException ignored )
        {
            return false;
        }
	}
	
	public void CloseWebView()
    {
        PackageManager pm = UnityPlayer.currentActivity.getPackageManager();
        Intent intent     = pm.getLaunchIntentForPackage(UnityPlayer.currentActivity.getPackageName());
        
        if( intent != null )
            UnityPlayer.currentActivity.startActivity(intent);
    }
	
	public static void LaunchApp( String packageName, String referrer )
    {
        Intent intent = UnityPlayer.currentActivity.getPackageManager().getLaunchIntentForPackage(packageName);
        if( intent != null )
        {
            // Activity was found, launch new app
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            if( referrer != null )
                intent.putExtra("lagoonxtra","lagoonxtra="+referrer);
            UnityPlayer.currentActivity.startActivity(intent);
        }
        else
        {
            // Activity not found. Send user to market
            intent = new Intent(Intent.ACTION_VIEW);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setData(Uri.parse("https://play.google.com/store/apps/details?id="+packageName+"&referrer="+referrer));
            intent.setPackage("com.android.vending");
            UnityPlayer.currentActivity.startActivity(intent);
        }
    }
}