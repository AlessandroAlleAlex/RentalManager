package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
      de.mintware.barcode_scan.BarcodeScanPlugin.registerWith(shimPluginRegistry.registrarFor("de.mintware.barcode_scan.BarcodeScanPlugin"));
      io.flutter.plugins.firebase.cloudfirestore.CloudFirestorePlugin.registerWith(shimPluginRegistry.registrarFor("io.flutter.plugins.firebase.cloudfirestore.CloudFirestorePlugin"));
      com.example.devicelocale.DevicelocalePlugin.registerWith(shimPluginRegistry.registrarFor("com.example.devicelocale.DevicelocalePlugin"));
    flutterEngine.getPlugins().add(new com.mr.flutter.plugin.filepicker.FilePickerPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebaseanalytics.FirebaseAnalyticsPlugin());
      io.flutter.plugins.firebaseauth.FirebaseAuthPlugin.registerWith(shimPluginRegistry.registrarFor("io.flutter.plugins.firebaseauth.FirebaseAuthPlugin"));
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.core.FirebaseCorePlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.database.FirebaseDatabasePlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.storage.FirebaseStoragePlugin());
    flutterEngine.getPlugins().add(new com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin());
      io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin.registerWith(shimPluginRegistry.registrarFor("io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"));
      io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin.registerWith(shimPluginRegistry.registrarFor("io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin"));
      com.baseflow.geolocator.GeolocatorPlugin.registerWith(shimPluginRegistry.registrarFor("com.baseflow.geolocator.GeolocatorPlugin"));
    flutterEngine.getPlugins().add(new com.baseflow.googleapiavailability.GoogleApiAvailabilityPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.googlemaps.GoogleMapsPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.googlesignin.GoogleSignInPlugin());
    flutterEngine.getPlugins().add(new vn.hunghd.flutter.plugins.imagecropper.ImageCropperPlugin());
      io.flutter.plugins.imagepicker.ImagePickerPlugin.registerWith(shimPluginRegistry.registrarFor("io.flutter.plugins.imagepicker.ImagePickerPlugin"));
      com.baseflow.location_permissions.LocationPermissionsPlugin.registerWith(shimPluginRegistry.registrarFor("com.baseflow.location_permissions.LocationPermissionsPlugin"));
    flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin());
    flutterEngine.getPlugins().add(new com.tekartik.sqflite.SqflitePlugin());
      com.wisecrab.wc_flutter_share.WcFlutterSharePlugin.registerWith(shimPluginRegistry.registrarFor("com.wisecrab.wc_flutter_share.WcFlutterSharePlugin"));
  }
}
