# Nayab Professional Store + POS Starter

This starter is prepared for the requested architecture:
- Professional customer website
- Django backend-ready structure
- Admin-ready product publishing controls
- Cart and customer orders
- Cash on Delivery + Account payment option placeholders
- Delivery-charge setting
- Order number and confirmation message flow
- Product ratings/reviews
- Online database configuration placeholder
- Offline POS/local storage architecture placeholder
- Barcode/product auto-recognition architecture

## Important
Do not put database passwords or admin passwords into frontend HTML/JavaScript.
The production Django server should store secrets in environment variables and hash admin passwords.

## Database
Put the future database connection string in environment variables/configuration on the server. The project intentionally does not contain a real database credential.

## Admin
The requested admin password can be set securely through Django's password system when the Django project is initialized.

## Run
This package is a starter interface/architecture, not a deployed production server. A real online database and domain require server hosting and the actual database connection details.
