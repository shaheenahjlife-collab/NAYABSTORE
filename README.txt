NAYAB STORE VIP POS v2
========================
1) Open sql/nayab_store_vip.sql in Supabase SQL Editor and Run it ONCE.
2) Open index.html in a modern browser.
3) Products, customers, salesmen and unsynced bills are stored locally in the browser.
4) When online, pending bills are sent to the Supabase orders table.
5) This package uses the supplied publishable Supabase key only. Never put a service-role/secret key in browser code.

IMPORTANT:
This is a browser-based VIP starter with offline queueing. A production deployment still needs Supabase RLS/auth, full transactional stock synchronization, purchase/return workflows, payment ledger tables, and conflict handling.
