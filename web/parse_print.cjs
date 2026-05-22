const fs = require('fs');
const phpContent = fs.readFileSync('/home/udin/SILATORJANA/web(lama)/app/views/pengusul/needs_work/print.php', 'utf8');

// Extract CSS
const cssMatch = phpContent.match(/<style>([\s\S]*?)<\/style>/);
const css = cssMatch ? cssMatch[1] : '';

// Save to a text file
fs.writeFileSync('print_css.txt', css);
console.log('CSS saved');
