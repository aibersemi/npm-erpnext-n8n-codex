#!/usr/bin/env node
// Automasi headless untuk login Nginx Proxy Manager (NPM)
// dan membuat Proxy Host + minta SSL Let's Encrypt.
// Konfigurasi lewat env:
//  - NPM_URL (default: http://npm.mrmads.shop:81)
//  - NPM_EMAIL, NPM_PASSWORD
//  - PROXY_DOMAIN (contoh: erp.mrmads.shop)
//  - FORWARD_HOST (contoh: erpnext-erpnext-nginx-1)
//  - FORWARD_PORT (default: 80)
//  - LE_EMAIL (email untuk Let's Encrypt)

const { chromium } = require('playwright');

async function ensure(value, name) {
  if (!value) {
    throw new Error(`Env ${name} wajib diisi`);
  }
  return value;
}

(async () => {
  const NPM_URL = process.env.NPM_URL || 'http://npm.mrmads.shop:81';
  const NPM_EMAIL = await ensure(process.env.NPM_EMAIL, 'NPM_EMAIL');
  const NPM_PASSWORD = await ensure(process.env.NPM_PASSWORD, 'NPM_PASSWORD');
  const PROXY_DOMAIN = await ensure(process.env.PROXY_DOMAIN, 'PROXY_DOMAIN');
  const FORWARD_HOST = process.env.FORWARD_HOST || 'erpnext-erpnext-nginx-1';
  const FORWARD_PORT = parseInt(process.env.FORWARD_PORT || '80', 10);
  const LE_EMAIL = await ensure(process.env.LE_EMAIL, 'LE_EMAIL');

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();
  page.setDefaultTimeout(30000);

  console.log(`[NPM] Buka login: ${NPM_URL}`);
  await page.goto(NPM_URL);

  // Form login
  await page.fill('input[type="email"]', NPM_EMAIL);
  await page.fill('input[type="password"]', NPM_PASSWORD);
  await page.click('button[type="submit"], button:has-text("Log in"), button:has-text("Sign in")');

  // Tunggu dashboard
  await page.waitForSelector('text=Proxy Hosts', { timeout: 60000 });
  console.log('[NPM] Login berhasil');

  // Masuk ke menu Proxy Hosts
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle' }),
    page.click('a:has-text("Proxy Hosts")')
  ]);

  // Klik Add Proxy Host
  const addSelector = 'button:has-text("Add Proxy Host"), a:has-text("Add Proxy Host")';
  await page.click(addSelector);

  // Isi form Proxy Host
  await page.fill('input[placeholder="e.g. mydomain.com"]', PROXY_DOMAIN);
  // Forward Hostname / IP
  await page.fill('input[placeholder="Forward Hostname / IP"]', FORWARD_HOST);
  // Forward Port
  await page.fill('input[placeholder="Forward Port"]', String(FORWARD_PORT));

  // Centang Websockets dan Block Common Exploits jika tersedia
  for (const label of ['Websockets Support', 'Block Common Exploits']) {
    const sel = `label:has-text("${label}") input[type="checkbox"]`;
    const el = await page.$(sel);
    if (el) {
      const checked = await el.isChecked();
      if (!checked) await el.check();
    }
  }

  // Pindah ke tab SSL
  await page.click('a:has-text("SSL")');
  // Pilih Request a new SSL Certificate
  await page.click('text=Request a new SSL Certificate');

  // Isi email LE jika ada field
  const emailField = await page.$('input[type="email"]');
  if (emailField) {
    // Jika ada lebih dari satu field email di halaman ini, pilih yang visible pada tab SSL
    try { await emailField.fill(LE_EMAIL); } catch {}
  }

  // Centang Force SSL, HTTP/2, HSTS, Agree
  for (const label of ['Force SSL', 'HTTP/2 Support', 'HSTS Enabled', "I Agree to Let's Encrypt Terms of Service"]) {
    const sel = `label:has-text("${label}") input[type="checkbox"]`;
    const el = await page.$(sel);
    if (el) {
      const checked = await el.isChecked();
      if (!checked) await el.check();
    }
  }

  // Simpan
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle' }),
    page.click('button:has-text("Save")')
  ]);

  // Verifikasi entri muncul di tabel
  await page.waitForSelector(`text=${PROXY_DOMAIN}`, { timeout: 60000 });
  console.log('[NPM] Proxy Host tersimpan:', PROXY_DOMAIN);

  await browser.close();
  console.log('[NPM] Selesai.');
  process.exit(0);
})().catch(err => {
  console.error('[NPM][ERROR]', err);
  process.exit(1);
});

