package com.binouze;

import android.content.pm.PackageManager;
import android.content.Intent;
import android.net.Uri;
import com.unity3d.player.UnityPlayer;
import androidx.browser.customtabs.CustomTabsIntent;
import android.util.DisplayMetrics;
import android.util.Log;

public class SimpleWebView
{
    public static boolean OpenWebView( String url, boolean cardView )
    {
        try
        {
            if( cardView )
            {
                DisplayMetrics displayMetrics = new DisplayMetrics();
                UnityPlayer.currentActivity
                        .getWindowManager()
                        .getDefaultDisplay()
                        .getMetrics(displayMetrics);

                int height = displayMetrics.heightPixels;
                int width  = displayMetrics.widthPixels;
                if( width > height )
                    height = width;
                    
                Log.d("SimpleWebView","SimpleWebView.OpenWebView as CardView -> displayMetric Height: "+height+" Width: "+width);

                CustomTabsIntent customTabsIntent = new CustomTabsIntent.Builder()
                        .setInitialActivityHeightPx(height*5,CustomTabsIntent.ACTIVITY_HEIGHT_FIXED)
                        .setToolbarCornerRadiusDp(10)
                        .setShareState(CustomTabsIntent.SHARE_STATE_OFF)
                        .build();

                customTabsIntent.intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
                customTabsIntent.intent.setData( Uri.parse(url) );

                UnityPlayer.currentActivity.startActivityForResult(customTabsIntent.intent, 1);
            }
            else
            {
                Log.d("SimpleWebView","SimpleWebView.OpenWebView Normal");

                CustomTabsIntent customTabsIntent = new CustomTabsIntent.Builder().build();
                customTabsIntent.intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
                customTabsIntent.launchUrl( UnityPlayer.currentActivity, Uri.parse(url) );
            }
        }
        catch( Exception e )
        {
            return false;
        }
        
        return true;
    }

    public static void CloseWebView()
    {
        Log.d("SimpleWebView","SimpleWebView.CloseWebView");


        PackageManager pm = UnityPlayer.currentActivity.getPackageManager();
        Intent intent     = pm.getLaunchIntentForPackage(UnityPlayer.currentActivity.getPackageName());

        if( intent != null )
        {
            Log.d("SimpleWebView","SimpleWebView.CloseWebView -> CLOSED ?");
            UnityPlayer.currentActivity.startActivity(intent);
        }
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

    public static boolean LaunchAppIfInstalled( String packageName, String referrer )
    {
        Intent intent = UnityPlayer.currentActivity.getPackageManager().getLaunchIntentForPackage(packageName);
        if( intent != null )
        {
            // Activity was found, launch new app
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            if( referrer != null )
                intent.putExtra("lagoonxtra","lagoonxtra="+referrer);
            UnityPlayer.currentActivity.startActivity(intent);

            return true;
        }

        return false;
    }
}