package com.greenplayapp;

import io.flutter.app.FlutterApplication;

public class Application extends FlutterApplication {
    @Override
    public void onCreate() {

        /// Test Strict mode.
        /*
        StrictMode.setThreadPolicy(new StrictMode.ThreadPolicy.Builder()
                .detectDiskReads()
                .detectDiskWrites()
                .detectAll()
                .penaltyLog()
                .build());

        StrictMode.setVmPolicy(new StrictMode.VmPolicy.Builder()
                .detectLeakedSqlLiteObjects()
                .detectLeakedClosableObjects()
                .penaltyLog()
                .penaltyDeath()
                .build());
        */

        super.onCreate();

        ///
        /// TEST onInitialized callback for custom MethodChannel
        ///
        /*
        HeadlessTask.onInitialized(new HeadlessTask.OnInitializedCallback() {
            @Override
            public void onInitialized(FlutterEngine engine) {
                Log.d("TSBackgroundFetch", "********* engine started: " + engine);
                new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), "channel_foo").setMethodCallHandler(new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                        Log.d("TSBackgroundFetch", "**************** Application method call handler: " + call.method);
                        result.success(true);
                    }
                });
            }
        });
        */

    }
}