# Codex Agent — DevOps Monorepo

Anda adalah Codex untuk proyek ini di VPS Ubuntu 22.04.
Repo: aibersemi/npm-erpnext-n8n-codex
Workspace: ~/projects/npm-erpnext-n8n-codex

## Tujuan layanan
- Nginx Proxy Manager (Docker) → npm.mrmads.shop
- ERPNext (Docker) → mrmads.shop
- n8n (Docker) → n8n.mrmads.shop

## Aturan keras
- Jangan utak-atik firewall (ufw/iptables).
- Selalu `git add/commit/push` setiap perubahan dengan pesan jelas.
- Gunakan Docker & Compose v2. Data persisten di `infra/<svc>/data|volumes`.
- Tulis file `.env.example` untuk contoh, **jangan commit** `.env` berisi rahasia.

## Kebiasaan eksekusi
- Boleh langsung baca, tulis & eksekusi (Full Access).
- Kerjakan semua instruksi tidak perlu ada konfirmasi, pilih menurut kamu paling baik, validasi setelah selesai sampai normal, jika belum normal perbaiki kembali, jika sudah normal dan beres tampilkan ringkas hasilnya.
- Setelah deploy service, lakukan validasi: `docker ps`, healthcheck, `curl http://127.0.0.1:<port>`.

## Kebijakan Docker
- NPM (jc21/nginx-proxy-manager:latest) port: 80, 443. Volume di `infra/nginx-proxy-manager/`.
- n8n (n8nio/n8n:latest), jalankan di belakang NPM. Atur `WEBHOOK_URL`/`N8N_HOST` sesuai domain. Volume di `infra/n8n/`.
- ERPNext gunakan images resmi komunitas (Frappe/ERPNext) dengan volume persisten. Jangan ekspose DB keluar.

## GitOps ringkas
- Setelah membuat/ubah file: `git add . && git commit -m "<pesan>" && git push`.

## Catatan DNS
- A/AAAA untuk domain mengarah ke VPS ini (IPv4 31.97.49.129, IPv6 2a02:4780:59:2c73::1).
- Contoh:
  - mrmads.shop → 31.97.49.129, 2a02:4780:59:2c73::1
  - npm.mrmads.shop → 31.97.49.129, 2a02:4780:59:2c73::1
  - n8n.mrmads.shop → 31.97.49.129, 2a02:4780:59:2c73::1

## Bahasa
- Gunakan selalu bahasa Indonesia dalam seluruh komunikasi, commit message, dan dokumentasi yang ditambahkan oleh agent.
