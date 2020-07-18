package com.example.callforwarding;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.Manifest;

import android.content.pm.PackageManager;
import android.net.Uri;
import androidx.core.app.ActivityCompat;

public class AlarmReceiver_SendOn extends BroadcastReceiver
{

    @Override
    public void onReceive(Context context, Intent intent) {

        Log.i("Executed", "Call Forwarding service started");

        String number = intent.getStringExtra("PhoneNumber");

        Intent i = new Intent(Intent.ACTION_CALL, Uri.parse("tel:" + "*21*" + number + Uri.encode("#")));
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED)
            return;
        context.startActivity(i);

        try {
            MainActivity.getInst().updateTV("Call Forwarding to: " + number);
        } catch (Exception e) {
            Log.i("Error", "Update TV fail" + e );
        }

        Log.i("Executed", "Service Forwarded to:" + number );

    }
}
