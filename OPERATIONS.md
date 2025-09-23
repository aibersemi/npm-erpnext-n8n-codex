# Panduan Operasional

Gunakan target `make` berikut untuk mengelola layanan:

- `make status` – melihat ringkasan kontainer penting (npm, n8n, erpnext-*)
- `make npm-up`, `make n8n-up`, `make erp-up` – menyalakan layanan masing-masing
- `make npm-logs`, `make n8n-logs`, `make erp-logs` – streaming log terakhir (tail 200)
- `make npm-down`, `make n8n-down`, `make erp-down` – mematikan layanan

Catatan: seluruh layanan berada pada network bersama bernama `proxy`, sehingga reverse proxy (NPM) dapat meneruskan trafik ke masing-masing layanan.

Domain yang digunakan saat ini:
- NPM: npm.mrmads.shop
- ERPNext: mrmads.shop
- n8n: n8n.mrmads.shop
