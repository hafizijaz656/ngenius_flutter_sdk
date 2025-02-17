# N-Genius Flutter SDK

N-Genius Flutter SDK provides an easy-to-use integration for handling payments using N-Genius APIs in Flutter applications.

## 📱 Platform Compatibility
- **Android** ✅


 <img src="https://github.com/user-attachments/assets/32896dc7-8056-4665-bd67-f992cad888f3" width="360" height="720" alt="android_ngenius_gif"/>


- **iOS** ✅ (Minimum deployment target: iOS 12.0)


<img src="https://github.com/user-attachments/assets/235cfc4f-05ef-4497-8e99-5aa66b8e9876" width="360" height="720" alt="ios_ngenius_gif"/>



## ⚙️ Android Configuration
### **Tested Environment**
This plugin has been tested with:
- **Android Gradle Plugin (AGP):** `8.1.0` [See here](https://github.com/mhammadraza137/ngenius_flutter_sdk/blob/960e0d6ad3fedff4e5fb42b054225e94486bee3c/example/android/settings.gradle#L21)
- **Kotlin Version:** `1.8.22` [See here](https://github.com/mhammadraza137/ngenius_flutter_sdk/blob/960e0d6ad3fedff4e5fb42b054225e94486bee3c/example/android/settings.gradle#L22)
- **Gradle Distribution:** `8.3` [See here](https://github.com/mhammadraza137/ngenius_flutter_sdk/blob/960e0d6ad3fedff4e5fb42b054225e94486bee3c/example/android/gradle/wrapper/gradle-wrapper.properties#L5)

### **Project-Level `build.gradle` Changes**
Since N-Genius SDK is a **JitPack dependency**, add the following line inside the `allprojects` repositories block in your **project-level** `android/build.gradle` file:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' } // Add this line
    }
}
```

## 🍏 iOS Configuration
No additional configuration is required for iOS.

## 🔄 N-Genius Response Model
The plugin returns a response object containing a **message** and a **code**. Below are the possible response scenarios:

### **🛑 Transaction Cancellation & Errors**
| Condition | Message | Code |
|-----------|------------|------|
| User cancels the transaction | `CANCELLED_BY_USER` | `401` |
| Order expired or generic error | `STATUS_GENERIC_ERROR` | `-1` |
| Payment failed | `STATUS_PAYMENT_FAILED` | `0` |

### **✅ Successful Payment Responses**
#### **🟢 Android**
| Payment Status | Message | Code |
|---------------|----------------------|------|
| Payment authorized | `PAYMENT_SUCCESSFUL` | `1` |
| Payment captured | `PAYMENT_SUCCESSFUL` | `2` |
| Payment purchased | `PAYMENT_SUCCESSFUL` | `3` |
| Post authorization review | `PAYMENT_SUCCESSFUL` | `4` |

#### **🍏 iOS**
The native **iOS N-Genius SDK** does not provide specific statuses like **authorized, captured, or purchased**. Instead, it returns a **generic success response**:

| Condition | Message | Code |
|-----------|----------------------|------|
| Transaction successful | `PAYMENT_SUCCESSFUL` | `200` |

---
### 🚀 **Get Started with N-Genius Flutter SDK**
1. Install the plugin in your Flutter project.
2. Configure **Android settings** as mentioned above.
3. Call the **N-Genius SDK** to launch the payment flow.

#### **Example Implementation**
```dart
class NgeniusExample extends StatelessWidget {
  const NgeniusExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('N-Genius Example'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              final ngeniusFlutterSdk = NgeniusFlutterSdk();
              NGeniusResponseModel ngeniusResponse = await ngeniusFlutterSdk.launchCardPayment(orderJsonObject: {});
              if (context.mounted) {
                if (ngeniusResponse.message == "PAYMENT_SUCCESSFUL") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction Successful")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "Transaction Failed :: code :: ${ngeniusResponse.code} :: message :: ${ngeniusResponse.message}")));
                }
              }
            },
            child: Text("Launch Card Payment")),
      ),
    );
  }
}
```

### **Passing the Order JSON Object to `launchCardPayment` Method**

To pass the `orderJsonObject` to the `launchCardPayment` method, you need to provide it against the `orderJsonObject` key. To get the `orderJsonObject`, you must first call two APIs. It is recommended to call these APIs on the server-side, not on the mobile side, for security and performance reasons.

#### **Steps to Get the Order JSON Object**

1. **Get the Access Token**  
   First, you need to obtain the access token by following the official N-Genius documentation:  
   [Request an Access Token](https://docs.ngenius-payments.com/reference/request-an-access-token-direct)

2. **Get the Order Object**  
   Once you have the access token, use it to call the API to get the order object. For more information, refer to the N-Genius documentation:  
   [Two-Stage Payments Orders](https://docs.ngenius-payments.com/reference/two-stage-payments-orders)

#### **Sample Order JSON Object**

After calling the APIs, you will receive the N-Genius order object. You can check the structure of the order object by referring to the official sample here:  
[Order Object in Full](https://docs.ngenius-payments.com/reference/the-order-object-in-full)

#### **Test Payment Using N-Genius Test Cards**

You can test payment using test cards for N-Genius from the following link:  
[Sandbox Test Environment](https://docs.ngenius-payments.com/reference/sandbox-test-environment)



For detailed documentation, refer to the official N-Genius API documentation.


## License

This project is licensed under the [MIT License](https://github.com/mhammadraza137/ngenius_flutter_sdk/blob/main/LICENSE).

---
📌 **Note:** If you encounter any issues, ensure all dependencies and configurations match the tested environment.

Happy coding! 🎉


