import figlet from 'figlet';
import {max} from 'lodash';

const READY_MSG = 'Flowyzer Engine is ready!';

function main(): void {
  const columns = process.stdout.columns ?? 80;
  const faros = figlet.textSync('Flowyzer', {
    horizontalLayout: 'fitted',
    verticalLayout: 'fitted',
    whitespaceBreak: true,
    width: columns,
  });
  const border = '-'.repeat(
    max(
      faros
        .split('\n')
        .concat(READY_MSG)
        .map((s) => s.length)
    ) ?? columns
  );
  console.log([border, faros, border, READY_MSG, border].join('\n'));
}

if (require.main === module) {
  main();
}
