import requests

RAZORPAY_TOKEN_URL = "https://payments.olivaclinic.com/api/token"
RAZORPAY_PAYMENT_URL = "https://payments.olivaclinic.com/api/payment"
RAZORPAY_USERNAME = "test@example.com"  # TODO: Replace with your username
RAZORPAY_PASSWORD = "123"  # TODO: Replace with your password

SHOPIFY_STORE = "your-store.myshopify.com"  # TODO: Replace
SHOPIFY_API_KEY = "your_api_key"  # TODO: Replace
SHOPIFY_PASSWORD = "your_password"  # TODO: Replace


def get_payment_token():
    data = {
        "username": RAZORPAY_USERNAME,
        "password": RAZORPAY_PASSWORD
    }
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
    }
    response = requests.post(RAZORPAY_TOKEN_URL, data=data, headers=headers)
    response.raise_for_status()
    return response.json().get("access_token")


def create_payment_link(token, payment_payload):
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Accept": "application/json, text/plain, */*"
    }
    response = requests.post(RAZORPAY_PAYMENT_URL, json=payment_payload, headers=headers)
    response.raise_for_status()
    return response.json()


def create_shopify_order(payment_data):
    headers = {"Content-Type": "application/json"}
    order_data = {
        "order": {
            "line_items": [
                {
                    "variant_id": 123456789,  # TODO: Replace with your product variant ID
                    "quantity": 1
                }
            ],
            "customer": {
                "first_name": payment_data.get("customer_name", "John"),
                "email": payment_data.get("email", "john@example.com")
            },
            "financial_status": "paid"
        }
    }
    response = requests.post(
        f"https://{SHOPIFY_API_KEY}:{SHOPIFY_PASSWORD}@{SHOPIFY_STORE}/admin/api/2024-04/orders.json",
        json=order_data,
        headers=headers
    )
    return response.status_code, response.json()