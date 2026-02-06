package com.example.fintech_sbmp

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.sathi.app/sim"
    private val PERMISSION_REQUEST_CODE = 123

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAllSimCards" -> {
                    if (checkPermissions()) {
                        val sims = getAllSimCards()
                        result.success(sims)
                    } else {
                        requestPermissions()
                        result.error("PERMISSION_DENIED", "Required permissions not granted", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkPermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_NUMBERS) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestPermissions() {
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            arrayOf(
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.READ_PHONE_NUMBERS
            )
        } else {
            arrayOf(Manifest.permission.READ_PHONE_STATE)
        }
        
        ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE)
    }

    private fun getAllSimCards(): List<Map<String, Any?>> {
        val simCards = mutableListOf<Map<String, Any?>>()
        
        try {
            val subscriptionManager = getSystemService(TELEPHONY_SERVICE) as? SubscriptionManager
            val telephonyManager = getSystemService(TELEPHONY_SERVICE) as? TelephonyManager
            
            if (subscriptionManager != null && ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.READ_PHONE_STATE
                ) == PackageManager.PERMISSION_GRANTED
            ) {
                val subscriptionInfoList: List<SubscriptionInfo>? = subscriptionManager.activeSubscriptionInfoList
                
                subscriptionInfoList?.forEachIndexed { index, info ->
                    val phoneNumber = info.number ?: ""
                    val carrierName = info.carrierName?.toString() ?: "Unknown"
                    val slotIndex = info.simSlotIndex
                    
                    // Determine if primary (slot 0 usually)
                    val isPrimary = slotIndex == 0
                    
                    simCards.add(
                        mapOf(
                            "phoneNumber" to phoneNumber.replace("+91", ""),
                            "carrierName" to carrierName,
                            "slotIndex" to slotIndex,
                            "isPrimary" to isPrimary
                        )
                    )
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        return simCards
    }
}