const fs = require('fs');
const phpContent = fs.readFileSync('/home/udin/SILATORJANA/web(lama)/app/views/pengusul/needs_work/print.php', 'utf8');

const cssMatch = phpContent.match(/<style>([\s\S]*?)<\/style>/);
let css = cssMatch ? cssMatch[1] : '';

// Just wrap the whole thing in .print-page-wrapper { ... }
// EXCEPT @media print { ... } which should be moved outside the wrapper
let mediaPrintMatch = css.match(/@media\s+print\s*{([\s\S]*?)}\s*$/);
let mediaPrint = mediaPrintMatch ? mediaPrintMatch[0] : '';
let cssWithoutMedia = css.replace(/@media\s+print\s*{([\s\S]*?)}\s*$/, '');

let scopedCss = `
.print-page-wrapper {
${cssWithoutMedia}
}

${mediaPrint}
`;

fs.writeFileSync('src/pages/pengusul/print.css', scopedCss);
console.log('Fixed CSS successfully.');
