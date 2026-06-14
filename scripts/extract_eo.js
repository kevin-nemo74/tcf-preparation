const https = require('https');
const fs = require('fs');
const path = require('path');

const BASE_URL = 'https://www.pack-tcf-canada.com/client/tache2_expo_oral.php';
const OUTPUT_DIR = path.resolve(__dirname, '..', 'assets', 'data', 'eo');
const INDEX_PATH = path.join(OUTPUT_DIR, 'index.json');
const SESSION_COOKIE = process.env.EO_PHP_SESSID || '';

function fetchUrl(url) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const opts = {
      hostname: u.hostname,
      path: u.pathname + u.search,
      rejectUnauthorized: false,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,*/*'
      }
    };
    if (SESSION_COOKIE) {
      opts.headers['Cookie'] = `PHPSESSID=${SESSION_COOKIE}`;
    }
    https.get(opts, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        fetchUrl(new URL(res.headers.location, url).toString()).then(resolve).catch(reject);
        return;
      }
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

function monthToSlugId(monthStr) {
  const s = monthStr.replace(/\+/g, ' ').toLowerCase();
  const map = {
    'january': 'janvier', 'february': 'fevrier', 'march': 'mars',
    'april': 'avril', 'may': 'mai', 'june': 'juin',
    'july': 'juillet', 'august': 'aout', 'september': 'septembre',
    'october': 'octobre', 'november': 'novembre', 'december': 'decembre'
  };
  const parts = s.split(' ');
  const en = parts[0];
  const year = parts[1];
  return `${map[en] || en}-${year}`;
}

function monthToDisplayName(monthStr) {
  const s = monthStr.replace(/\+/g, ' ');
  const map = {
    'january': 'Janvier', 'february': 'Février', 'march': 'Mars',
    'april': 'Avril', 'may': 'Mai', 'june': 'Juin',
    'july': 'Juillet', 'august': 'Août', 'september': 'Septembre',
    'october': 'Octobre', 'november': 'Novembre', 'december': 'Décembre'
  };
  const parts = s.split(' ');
  const en = parts[0].toLowerCase();
  const year = parts[1];
  return `${map[en] || parts[0]} ${year}`;
}

function parseParties(html) {
  const parties = [];
  const cardRe = /<div\s+class="tache-card">([\s\S]*?)<\/div>/g;
  let m;
  while ((m = cardRe.exec(html)) !== null) {
    const inner = m[1];
    const items = [];
    const liRe = /<li>([\s\S]*?)<\/li>/g;
    let lm;
    while ((lm = liRe.exec(inner)) !== null) {
      let txt = lm[1].replace(/<[^>]+>/g, '').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#039;/g, "'").replace(/&#8288;/g, '').trim();
      if (txt) items.push(txt);
    }
    if (items.length > 0) parties.push(items);
  }
  return parties;
}

async function main() {
  console.log('Fetching main page...');
  const mainHtml = await fetchUrl(BASE_URL);
  console.log(`Got ${mainHtml.length} bytes`);

  const monthSet = new Set();
  const linkRe = /<a\s+href="\?month=([^"]+)"[^>]*>/g;
  let li;
  while ((li = linkRe.exec(mainHtml)) !== null) {
    const raw = li[1].replace(/\+/g, ' ');
    monthSet.add(raw);
  }

  const months = [...monthSet];
  console.log(`Found ${months.length} months`);

  if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });

  const indexMonths = [];

  for (const month of months) {
    const query = month.replace(/ /g, '+');
    const url = `${BASE_URL}?month=${query}`;
    console.log(`Fetching ${month}...`);
    const html = await fetchUrl(url);

    const parties = parseParties(html);
    console.log(`  → ${parties.length} parties`);

    const id = monthToSlugId(month);
    const examTitle = monthToDisplayName(month);
    indexMonths.push({ id, examTitle });

    const data = {
      id,
      examTitle,
      parties: parties.map((items, i) => ({
        title: items[0] || `Partie ${i + 1}`,
        sujets: items.slice(1)
      }))
    };

    const fp = path.join(OUTPUT_DIR, `${id}.json`);
    fs.writeFileSync(fp, JSON.stringify(data, null, 2), 'utf-8');
    console.log(`  → wrote ${fp}`);
  }

  fs.writeFileSync(INDEX_PATH, JSON.stringify({ description: "Expression Orale - Tâche 2 - TCF Canada", months: indexMonths }, null, 2), 'utf-8');
  console.log(`\nDone! Index at ${INDEX_PATH}`);
}

main().catch(console.error);
