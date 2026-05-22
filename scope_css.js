const fs = require('fs');
let css = fs.readFileSync('src/pages/pengusul/print.css', 'utf8');

// We just want to prefix any rule that doesn't start with .print-page-wrapper, @media, or a few safe ones
// Actually, it's safer to just inject `.print-page-wrapper ` before every selector block.
css = css.replace(/^(?!@media|\.print-page-wrapper| {8}\.print-page-wrapper)(\s*)([a-zA-Z\.#][^{]*?)\s*{/gm, '$1.print-page-wrapper $2 {');

fs.writeFileSync('src/pages/pengusul/print.css', css);
console.log('Scoped CSS successfully.');
