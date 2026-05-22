const fs = require('fs');
let css = fs.readFileSync('src/pages/pengusul/print.css', 'utf8');

css = css.replace(/^(?!@media|\.print-page-wrapper| {8}\.print-page-wrapper)(\s*)([a-zA-Z\.#][^{]*?)\s*{/gm, '$1.print-page-wrapper $2 {');

fs.writeFileSync('src/pages/pengusul/print.css', css);
console.log('Scoped CSS successfully.');
