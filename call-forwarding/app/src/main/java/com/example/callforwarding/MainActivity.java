package com.example.callforwarding;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.provider.OpenableColumns;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;

public class MainActivity extends AppCompatActivity implements MyBroadcastListener {

    private static final int PERMISSION_REQUEST_STORAGE = 1000;
    private static final int READ_REQUEST_CODE=42;

    private BroadcastReceiver receiver;
    private AlarmManager m_alarmMgr;
    private AlarmManager m_alarmMgr2;
    private IntentFilter filter;
    private static MainActivity ins;

    Calendar calendar = Calendar.getInstance();
    PendingIntent m_alarmIntent;
    PendingIntent m_alarmIntent2;
    Button boton_de_carga;
    String globalUri = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        ins = this;
        filter = new IntentFilter("com.example.callforwarding");
        receiver = new SetAlarms_SendOn(this);

        final Button buttonStart = findViewById(R.id.button_start);
        boton_de_carga = (Button) findViewById(R.id.boton_de_carga);
        boton_de_carga.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                realizarBusquedaDeArchivo();
            }
        });

        buttonStart.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                registerReceiver(receiver, filter);

                try {
                    ArrayList<String> horas = leerArchivo(globalUri, "horas");
                    Log.i("Executed", "Hours: " + horas.toString());
                    ArrayList<String> numeros = leerArchivo(globalUri,"numeros");
                    Log.i("Executed", "Numbers: " + numeros.toString());
                    setAlarms(horas, numeros);

                    Toast.makeText(MainActivity.this, "Hours: " + horas.toString() + " Numbers: " + numeros.toString(), Toast.LENGTH_LONG).show();
                    Handler handler = new Handler();
                    handler.postDelayed(new Runnable()
                    {
                        @Override
                        public void run()
                        {
                            Toast.makeText(MainActivity.this, "Service Started", Toast.LENGTH_SHORT).show();
                        }
                    }, 3500);

                    buttonStart.setClickable(false);

                } catch (Exception e) {
                    Toast.makeText(MainActivity.this, "No File Uploaded", Toast.LENGTH_LONG).show();
                    Log.i("Error", "No File: " + e);
                }

            }
        });


        final Button buttonStop = findViewById(R.id.button_stop);
        buttonStop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                cancelAlarms();
            }
        });
    }

    public void cancelAlarms() {
        if (m_alarmMgr != null) {
            m_alarmMgr.cancel(m_alarmIntent);
            Toast.makeText(MainActivity.this, "Service Stopped", Toast.LENGTH_LONG).show();
            Log.i("Executed", "Alarms Canceled (SetAlarm)");
        }
        if (m_alarmMgr2 != null) {
            m_alarmMgr2.cancel(m_alarmIntent2);
            Toast.makeText(MainActivity.this, "Service Stopped", Toast.LENGTH_LONG).show();
            Log.i("Executed", "Alarms Canceled (SetFutureStartTime)");
        }
    }

    //Start set alarms task when user starts from button
    public void setAlarms(ArrayList<String> time, ArrayList<String> number)
    {
        Context context = this;

        m_alarmMgr = (AlarmManager)getSystemService(Context.ALARM_SERVICE);
        Intent i = new Intent("com.example.callforwarding");

        i.putStringArrayListExtra("PhoneNumber", number);
        i.putStringArrayListExtra("GivenTime", time);

        calendar.setTimeInMillis(System.currentTimeMillis());
        int sys_hour = calendar.get(Calendar.HOUR_OF_DAY);
        int sys_min = calendar.get(Calendar.MINUTE);
        int sys_sec = calendar.get(Calendar.SECOND);
        calendar.set(Calendar.HOUR_OF_DAY, sys_hour);
        calendar.set(Calendar.MINUTE, sys_min);
        calendar.set(Calendar.SECOND, sys_sec + 10);

        m_alarmIntent = PendingIntent.getBroadcast(this, (int) System.currentTimeMillis(), i, PendingIntent.FLAG_UPDATE_CURRENT);
        m_alarmMgr.setRepeating(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), AlarmManager.INTERVAL_DAY, m_alarmIntent); //AlarmManager.INTERVAL_FIFTEEN_MINUTES, pending);

        DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

        Log.i("Executed", "Alarm Setting Task (SetAlarm Method)");
        Log.i("Executed", "Main alarms set at:" + df.format(calendar.getTime()));
    }

    @Override
    public void SetFutureStartTime(int startHour, int startMin, String number, boolean nextDay)
    {
        boolean index=false;
        Context context = this;

        m_alarmMgr2 = (AlarmManager)getSystemService(Context.ALARM_SERVICE);

        Intent intent = new Intent(this, com.example.callforwarding.AlarmReceiver_SendOn.class);
        intent.putExtra("PhoneNumber", number);
        m_alarmIntent2 = PendingIntent.getBroadcast(this, (int) System.currentTimeMillis(), intent, PendingIntent.FLAG_UPDATE_CURRENT);

        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());
        calendar.set(Calendar.HOUR_OF_DAY, startHour);
        calendar.set(Calendar.MINUTE, startMin);

        if(nextDay)
            calendar.add(Calendar.DAY_OF_WEEK,1);

        DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

        m_alarmMgr2.setExact(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), m_alarmIntent2);
        Log.i("Executed", "Alarm Setting Task (SetFutureStartTime Method)");
        Log.i("Executed", "Call Forwarding alarm set at:" + df.format(calendar.getTime()));

    }

    public static MainActivity getInst(){
        return ins;
    }

    public void updateTV(final String t) {
        MainActivity.this.runOnUiThread(new Runnable() {
            public void run() {
                TextView tvp = (TextView) findViewById(R.id.textview_pri);
                tvp.setText(t);
            }
        });
    }

    private void realizarBusquedaDeArchivo(){
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        //Se filtran los nombres por tipo de MIME en este caso texto
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("text/*");
        startActivityForResult(intent, READ_REQUEST_CODE);
    }

    //Se llama al método onActivityResult para extraer el URI del archivo seleccionado después de realizarBusquedaDeArchivo().
    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == READ_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                Uri uri = data.getData();
                //Se obtiene el path del archivo a partir del URI
                String path = uri.getPath();
                //Se modifica la cadena ya que solo se necesita la parte después de ":"
                path = "/" + path.substring(path.indexOf(":") + 1);
                //Hay casos en los que se tiene el path con la cadena "document", y éste no contiene de mandera correcta el path
                if (path.contains("document")) {
                    Cursor returnCursor = getContentResolver().query(uri, null, null, null, null);
                    //Se obtiene el nombre del fichero
                    int nameIndex = returnCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                    returnCursor.moveToFirst();
                    //Se hace una cadena con un path creado, con el nombre del archivo, suponiendo que el fichero está en la carpeta de descargas
                    path = "/Download/" + returnCursor.getString(nameIndex);
                }
                globalUri = path;
            }
        }

    }

    public ArrayList<String> leerArchivo(String input, String tipo_de_contenido){
        File file = new File(Environment.getExternalStorageDirectory(), input);
        ArrayList<String> arreglo_de_texto= new ArrayList<String>();
        try{
            BufferedReader br = new BufferedReader(new FileReader(file));
            String line;
            //Se lee el archivo para extraer las horas
            if(tipo_de_contenido == "horas"){
                String cadena_de_horas = br.readLine();
                String[] array_cadena_de_horas = cadena_de_horas.split(" ");
                for(int i =0; i < array_cadena_de_horas.length; i++){
                    arreglo_de_texto.add(array_cadena_de_horas[i]);
                }

            }
            // Se lee el archivo para extraer los números
            else{
                //Se salta la primera linea que contiene los números
                br.readLine();
                //Guarda el resto de números en un array
                while((line = br.readLine()) != null ){
                    //se agrega la linea borrando los espacios
                    arreglo_de_texto.add(line.replace(" ",""));
                }
            }
            br.close();
        } catch (IOException e){
            e.printStackTrace();
            Toast.makeText(this, "File not found: " +e, Toast.LENGTH_SHORT).show();
        }
        return arreglo_de_texto;
    }

    @Override
    public void onDestroy(){
        super.onDestroy();
        try {
            cancelAlarms();
        } catch (Exception ex) {
        }
    }
}

