package com.example.callforwarding;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.util.ArrayList;
import java.util.Calendar;

public class SetAlarms_SendOn extends BroadcastReceiver
{
    private MyBroadcastListener listener;

    public SetAlarms_SendOn(MyBroadcastListener listener){
        this.listener = listener;
    }

    int indAux=0;
    @Override
    public void onReceive(Context context, Intent intent) {
        Log.i("Executed", "BroadcastReceiver (onReceive Method)");

        ArrayList<String> number = intent.getExtras().getStringArrayList("PhoneNumber");
        ArrayList<String> given_time = intent.getExtras().getStringArrayList("GivenTime");

        boolean nextDay=true;

        Calendar calendar = Calendar.getInstance();
        int sys_hour = calendar.get(Calendar.HOUR_OF_DAY);
        int sys_min = calendar.get(Calendar.MINUTE);

        ArrayList<String> auxList = new ArrayList<String>();

        int inicio = (indAux * given_time.size())%(number.size());
        int fin = (inicio + given_time.size());

        for(int i=inicio; i<fin; i++)
            auxList.add(number.get(i%number.size()));

        int j=-1;

        for(int i=0; i< given_time.size(); i++) {

            String[] time = given_time.get(i).split ( ":" );
            int hour = Integer.parseInt ( time[0].trim() );
            int min = Integer.parseInt ( time[1].trim() );

            if(j == auxList.size()-1){
                j=0;
            }else{
                j++;
            }

            //This set the alarms for the next 24 HRS
            if (((hour == sys_hour) && (min > sys_min)) || (hour > sys_hour)){
                nextDay=false;
            }
            listener.SetFutureStartTime(hour, min, auxList.get(j), nextDay);

        }

        indAux++;
        auxList.clear();
    }
}
