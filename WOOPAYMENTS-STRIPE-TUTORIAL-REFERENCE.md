# WooCommerce Payments - Stripe Integration Reference for Tutorials

## Summary
WooCommerce Payments is built on Stripe infrastructure. Merchants using WooPay already have Stripe accounts and can use the Stripe SDK for custom integrations.

## Key Technical Details

### 1. Stripe.js Integration
- **Location**: `includes/class-wc-payments-checkout.php:122-128`
- WooCommerce Payments loads Stripe.js v3 from `https://js.stripe.com/v3/`
- Uses the same SDK as standalone Stripe plugin

### 2. Publishable Key Access

#### Via PHP (Account Service)
```php
// Location: includes/class-wc-payments-checkout.php:186
$account_service = WC_Payments::get_account_service();
$is_test_mode = WC_Payments::mode()->is_test();
$publishable_key = $account_service->get_publishable_key($is_test_mode);
$account_id = $account_service->get_stripe_account_id();
```

#### Via JavaScript (Frontend)
```javascript
// Available on checkout page in wcpay_upe_config object
console.log('Publishable Key:', wcpay_upe_config.publishableKey);
console.log('Account ID:', wcpay_upe_config.accountId);
console.log('Test Mode:', wcpay_upe_config.testMode);
```

#### Key Storage
- **File**: `includes/class-wc-payments-account.php:166-178`
- Test mode: `$account['test_publishable_key']`
- Live mode: `$account['live_publishable_key']`

### 3. WordPress Filter Hook
- **Hook**: `wcpay_payment_fields_js_config`
- **Location**: `includes/class-wc-payments-checkout.php:224`
- Allows modifying the JavaScript configuration before it's passed to frontend

## Tutorial Implementation Strategies

### Option 1: Admin Notice Helper (Recommended)
Add to `functions.php` or custom plugin:

```php
/**
 * Display WooCommerce Payments Stripe Keys
 * For tutorial/development purposes only - remove after use
 */
add_action('admin_notices', function() {
    if (!current_user_can('manage_woocommerce')) {
        return;
    }

    if (!class_exists('WC_Payments')) {
        return;
    }

    $account_service = WC_Payments::get_account_service();
    if (!$account_service) {
        return;
    }

    $is_test_mode = WC_Payments::mode()->is_test();
    $publishable_key = $account_service->get_publishable_key($is_test_mode);
    $account_id = $account_service->get_stripe_account_id();

    if ($publishable_key) {
        echo '<div class="notice notice-info is-dismissible">';
        echo '<h3>WooCommerce Payments - Stripe Credentials</h3>';
        echo '<p><strong>Mode:</strong> ' . ($is_test_mode ? 'Test Mode' : 'Live Mode') . '</p>';
        echo '<p><strong>Publishable Key:</strong> <code style="user-select: all;">' . esc_html($publishable_key) . '</code></p>';
        echo '<p><strong>Stripe Account ID:</strong> <code style="user-select: all;">' . esc_html($account_id) . '</code></p>';
        echo '<p><em>⚠️ Remove this code snippet after copying your keys!</em></p>';
        echo '</div>';
    }
});
```

### Option 2: Browser Console Method
Instruct users to:
1. Navigate to WooCommerce checkout page
2. Open browser Developer Tools (F12)
3. Go to Console tab
4. Run:
```javascript
// Copy publishable key
copy(wcpay_upe_config.publishableKey);
console.log('✓ Publishable key copied to clipboard!');
console.log('Account ID:', wcpay_upe_config.accountId);
```

### Option 3: Custom Filter Hook
For advanced users needing programmatic access:

```php
add_filter('wcpay_payment_fields_js_config', function($config) {
    // Expose to custom JavaScript variable for tutorial purposes
    wp_add_inline_script('your-custom-script',
        'window.myStripeConfig = ' . wp_json_encode([
            'publishableKey' => $config['publishableKey'],
            'accountId' => $config['accountId'],
            'testMode' => $config['testMode']
        ]),
        'before'
    );
    return $config;
}, 10);
```

## Tutorial User Instructions Template

### For WooCommerce Payments Users:

**Step 1: Get Your Stripe Publishable Key**

Your WooCommerce Payments account is powered by Stripe. To use it with the Stripe SDK:

1. Add the helper code (Option 1 above) to your site temporarily
2. Navigate to WordPress Admin Dashboard
3. Look for the "WooCommerce Payments - Stripe Credentials" notice
4. Copy your **Publishable Key** (starts with `pk_test_` or `pk_live_`)
5. Copy your **Stripe Account ID**
6. Remove the helper code

**OR use Browser Console (simpler):**
1. Go to your checkout page
2. Press F12 to open Developer Tools
3. Run: `copy(wcpay_upe_config.publishableKey)`
4. Your key is now in your clipboard

**Step 2: Initialize Stripe SDK**

```javascript
// Use your copied publishable key
const stripe = Stripe('pk_test_XXXXXXXXXXXXX');

// Now you can use standard Stripe SDK features
const elements = stripe.elements();
// ... continue with your integration
```

**Step 3: Understanding Your Setup**
- WooCommerce Payments = Stripe under the hood
- Same payment methods, same infrastructure
- Your Stripe account is managed through WooCommerce Payments
- All Stripe SDK tutorials work with your account

## Important Notes

### Security Reminders for Tutorials:
1. ✅ Publishable keys are SAFE to expose client-side (that's their purpose)
2. ⚠️ NEVER expose secret/private keys
3. 🔒 Always use test mode keys for tutorials (start with `pk_test_`)
4. 🗑️ Remove helper code after obtaining keys
5. 📝 Remind users to verify test mode vs live mode

### Compatibility:
- **Stripe.js Version**: v3
- **Stripe Account Type**: Connect platform account
- **Connected Account ID**: Available in `wcpay_upe_config.accountId`
- **UPE Mode**: Unified Payment Element (modern Stripe integration)

### WooPay Specific Features:
- WooPay host: `wcpay_upe_config.woopayHost`
- Express checkout enabled: `wcpay_upe_config.isWooPayExpressCheckoutEnabled`
- Requires proper WooPay setup before use

## Reference File Locations

| Feature | File Path | Line |
|---------|-----------|------|
| Stripe.js Loading | `includes/class-wc-payments-checkout.php` | 122-128 |
| Publishable Key Config | `includes/class-wc-payments-checkout.php` | 186 |
| Account Data Retrieval | `includes/class-wc-payments-account.php` | 166-178 |
| Filter Hook | `includes/class-wc-payments-checkout.php` | 224, 292 |
| JS Config Object | Frontend: `wcpay_upe_config` | Runtime |

## Example Use Cases for Tutorials

1. **Custom Payment Forms**: Use Stripe Elements with WooPay credentials
2. **Mobile App Integration**: Use publishable key with Stripe mobile SDKs
3. **Subscription Management**: Access Stripe Customer Portal
4. **Custom Checkout Flows**: Build alternative payment experiences
5. **Payment Method Testing**: Test different Stripe payment methods
6. **Webhook Development**: Use Stripe account for webhook testing

---

**Created**: 2025-10-23
**Plugin**: WooCommerce Payments
**Purpose**: Tutorial development reference for Stripe SDK integration
