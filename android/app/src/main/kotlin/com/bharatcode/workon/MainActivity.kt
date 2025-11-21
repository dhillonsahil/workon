package com.bharatcode.workon

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings
import android.util.Log
import com.google.android.vending.licensing.LicenseChecker
import com.google.android.vending.licensing.LicenseCheckerCallback
import com.google.android.vending.licensing.AESObfuscator
import com.google.android.vending.licensing.ServerManagedPolicy
import android.content.Context
import android.net.ConnectivityManager
import androidx.core.content.ContextCompat

class MainActivity : FlutterActivity() {

    // --- CONFIGURE THESE ---
    private val CHANNEL = "license_check"
    private val BASE64_PUBLIC_KEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApRDxT4CEqU6qvKXSdAQrRcZH7yntykBCgbec7g0I3s7npTQutP1dpRargOL9Ik7v1zVugEUSHc4K4ImrJByr1RKPIIhyjzkNvjc8omZ9479Q0I7bOZpsZahRRplkchsJyIetRXBQOMCQUDXfqBctU+H9NSDJFDdUhUI/6eHt/vRelFBGkqU4fXyBK9ChzItltoyLx4cXj9Sqtmimm1ILQkq3o44CSqctr0+zW5oN6IlVVGZSlMyFhsgv0vxc8pHzZt/UEfYZ58bsnXwycqQrHwJqVp4PL/DYURXNkg4EnVRUTsgtiNo3kCOPMiQESPf3EquOOvoyehaaN/gYLnFHGQIDAQAB"  // ← Paste from Play Console
    private val SALT = byteArrayOf(
        250, 130, 208, 52, 128, 106, 235, 35, 44, 217,
        124, 164, 11, 61, 153, 155, 187, 224, 17, 46
    )
    // -----------------------

    private var pendingResult: MethodChannel.Result? = null
    private var checker: LicenseChecker? = null
    private val TAG = "LicenseCheck"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "verifyLicense" -> {
                        pendingResult = result
                        checkLicense()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun checkLicense() {
        if (!isNetworkAvailable()) {
            Log.w(TAG, "No internet — assuming licensed (offline mode)")
            finishResult(true)
            return
        }

        val deviceId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
        val obfuscator = AESObfuscator(SALT, packageName, deviceId)
        val policy = ServerManagedPolicy(this, obfuscator, deviceId)
        checker = LicenseChecker(this, policy, BASE64_PUBLIC_KEY)

        checker!!.checkAccess(object : LicenseCheckerCallback {
            override fun allow(reason: Int) {
                Log.i(TAG, "License ALLOWED (reason: $reason)")
                finishResult(true)
            }

            override fun dontAllow(reason: Int) {
                Log.w(TAG, "License DENIED (reason: $reason)")
                finishResult(false)
            }

            override fun applicationError(errorCode: Int) {
                Log.e(TAG, "License ERROR (code: $errorCode)")
                // Be forgiving on error (or return false)
                finishResult(true)
            }
        })
    }

    private fun finishResult(licensed: Boolean) {
        pendingResult?.success(licensed)
        cleanup()
    }

    private fun cleanup() {
        checker?.onDestroy()
        checker = null
        pendingResult = null
    }

    private fun isNetworkAvailable(): Boolean {
        val cm = ContextCompat.getSystemService(this, ConnectivityManager::class.java)
        val activeNetwork = cm?.activeNetworkInfo
        return activeNetwork?.isConnectedOrConnecting == true
    }

    override fun onDestroy() {
        cleanup()
        super.onDestroy()
    }
}