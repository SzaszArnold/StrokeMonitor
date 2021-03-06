package com.example.strokemonitor;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

public class MyService extends Service {

    @Override
    public void onCreate() {
        super.onCreate();
        Intent notificationIntent = new Intent(this,MainActivity.class);
        PendingIntent conPendingIntent = PendingIntent.getActivity(this,0,notificationIntent,PendingIntent.FLAG_UPDATE_CURRENT);
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this,"messages")
                    .setContentText("Stroke monitor running in Background")
                    .setContentTitle("StrokeMonitor")
                    .setSmallIcon(R.mipmap.ic_launcher_foreground)
                    .setContentIntent(conPendingIntent);
            startForeground(101,builder.build());
        }

    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}