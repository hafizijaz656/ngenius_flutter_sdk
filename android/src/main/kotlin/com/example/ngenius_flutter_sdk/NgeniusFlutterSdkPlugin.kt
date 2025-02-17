package com.example.ngenius_flutter_sdk

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import payment.sdk.android.PaymentClient
import payment.sdk.android.cardpayment.CardPaymentData
import payment.sdk.android.cardpayment.CardPaymentRequest
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject

/** NgeniusFlutterSdkPlugin */
class NgeniusFlutterSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {

  private lateinit var channel : MethodChannel
  private lateinit var paymentClient: PaymentClient
  private var activity: Activity? = null
  private var pendingResult: Result? = null

  companion object {
    private const val CARD_PAYMENT_REQUEST_CODE = 123
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ngenius_flutter_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "launchCardPayment") {
      try {
        val jsonData = call.argument<HashMap<String, Any>>("orderJsonObject")
          ?: throw IllegalArgumentException("orderJsonObject is required")

        val links = (jsonData["_links"] as? HashMap<String, Any>)
          ?: throw Exception("_links not found in orderJsonObject")

        val authUrl = ((links["payment-authorization"] as? HashMap<String, Any>)?.get("href") as? String)
          ?: throw Exception("Authorization URL not found in orderJsonObject")

        val paymentUrl = ((links["payment"] as? HashMap<String, Any>)?.get("href") as? String)
          ?: throw Exception("Payment URL not found in orderJsonObject")


        val code = if (paymentUrl.contains("code=")) {
          paymentUrl.substringAfter("code=").takeIf { it.isNotEmpty() }
            ?: throw Exception("Code value is empty in orderJsonObject")
        } else {
          throw Exception("Code parameter not found in payment URL")
        }

        pendingResult = result
        activity?.let { currentActivity ->
          paymentClient = PaymentClient(currentActivity, "DEMO_VAL")
          paymentClient.launchCardPayment(
            CardPaymentRequest.Builder()
              .gatewayUrl(authUrl)
              .code(code)
              .build(),
            CARD_PAYMENT_REQUEST_CODE
          )
        } ?: result.error(
          "NO_ACTIVITY",
          "No activity available",
          null
        )
      } catch (e: Exception) {
        result.error(
          "LAUNCH_ERROR",
          e.message ?: "Unknown error occurred",
          null
        )
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  @Override
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    return if (requestCode == CARD_PAYMENT_REQUEST_CODE) {
      when (resultCode) {
        Activity.RESULT_OK -> {
          if(data != null){
            val cardPaymentData = CardPaymentData.getFromIntent(data)
            cardPaymentData?.let {
              val resultMessage = when (it.code) {
                CardPaymentData.STATUS_PAYMENT_AUTHORIZED,
                CardPaymentData.STATUS_PAYMENT_CAPTURED,
                CardPaymentData.STATUS_POST_AUTH_REVIEW,
                CardPaymentData.STATUS_PAYMENT_PURCHASED -> "PAYMENT_SUCCESSFUL"

                CardPaymentData.STATUS_PAYMENT_FAILED -> "STATUS_PAYMENT_FAILED"
                CardPaymentData.STATUS_GENERIC_ERROR -> "STATUS_GENERIC_ERROR"
                else -> "Unknown payment response: ${it.reason}"
              }
              val ngeniusResponse = mapOf(
                "code" to cardPaymentData.code,
                "reason" to resultMessage,
              )
              val jsonString = org.json.JSONObject(ngeniusResponse).toString()
              pendingResult?.success(jsonString)
            }
          }
        }
        Activity.RESULT_CANCELED -> {
          val cancelMap = mapOf(
            "code" to 401,
            "reason" to "CANCELLED_BY_USER",
          )
          val jsonString = org.json.JSONObject(cancelMap).toString()
          pendingResult?.success(jsonString)
        }
      }
      true
    } else {
      false
    }
  }

}
