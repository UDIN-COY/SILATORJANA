import fs from 'node:fs/promises';
import { createWriteStream } from 'node:fs';
import { pipeline } from 'node:stream/promises';
import { Readable } from 'node:stream';
import path from 'node:path';

async function downloadAndExtract() {
  const url = 'https://codeberg.org/api/v1/repos/UDINK/silatorjana/archive/main.zip';
  console.log(`Downloading ${url}...`);
  const response = await fetch(url);
  if (!response.ok) throw new Error(`bad response: ${response.status} ${response.statusText}`);
  
  await pipeline(
    Readable.fromWeb(response.body as any),
    createWriteStream('repo.zip')
  );
  console.log('Downloaded repo.zip');
}
downloadAndExtract().catch(console.error);
