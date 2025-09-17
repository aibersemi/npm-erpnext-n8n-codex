# Codex Agent — DevOps Monorepo

Anda adalah Codex untuk proyek ini di VPS Ubuntu 22.04.
Repo: aibersemi/npm-erpnext-n8n-codex
Workspace: ~/projects/npm-erpnext-n8n-codex

## Tujuan layanan
- Nginx Proxy Manager (Docker) → npm.mrmads.shop
- ERPNext (Docker) → erp.mrmads.shop
- n8n (Docker) → n8n.mrmads.shop

## Aturan keras
- Jangan utak-atik firewall (ufw/iptables).
- Bekerja HANYA di workspace ini.
- Selalu `git add/commit/push` setiap perubahan dengan pesan jelas.
- Gunakan Docker & Compose v2. Data persisten di `infra/<svc>/data|volumes`.
- Jangan buka port selain yang dibutuhkan (80/443/81 dll).
- Tulis file `.env.example` untuk contoh, **jangan commit** `.env` berisi rahasia.

## Kebiasaan eksekusi
- Boleh langsung baca/tulis & menjalankan perintah (Full Access).
- Kerjakan **satu langkah** per instruksi user. Tampilkan perintah yang dijalankan dan ringkas hasilnya.
- Setelah deploy service, lakukan validasi: `docker ps`, healthcheck, `curl http://127.0.0.1:<port>`.

## Kebijakan Docker
- Gunakan network bersama bernama `proxy` (external) untuk NPM & semua app di belakangnya.
- NPM (jc21/nginx-proxy-manager:latest) port: 80, 81 (UI), 443. Volume di `infra/nginx-proxy-manager/`.
- n8n (n8nio/n8n:latest), jalankan di belakang NPM. Atur `WEBHOOK_URL`/`N8N_HOST` sesuai domain. Volume di `infra/n8n/`.
- ERPNext gunakan images resmi komunitas (Frappe/ERPNext) dengan volume persisten. Jangan ekspose DB keluar.

## GitOps ringkas
- Setelah membuat/ubah file: `git add . && git commit -m "<pesan>" && git push`.

## Catatan DNS
- Asumsi A/AAAA record untuk subdomain mengarah ke VPS ini (IPv4 31.97.49.129, IPv6 2a02:4780:59:2c73::1).

