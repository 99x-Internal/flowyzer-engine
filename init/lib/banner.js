"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const figlet_1 = __importDefault(require("figlet"));
const lodash_1 = require("lodash");
const READY_MSG = 'Faros Community Edition is ready!';
function main() {
    var _a, _b;
    const columns = (_a = process.stdout.columns) !== null && _a !== void 0 ? _a : 80;
    const faros = figlet_1.default.textSync('Faros', {
        horizontalLayout: 'fitted',
        verticalLayout: 'fitted',
        whitespaceBreak: true,
        width: columns,
    });
    const border = '-'.repeat((_b = (0, lodash_1.max)(faros
        .split('\n')
        .concat(READY_MSG)
        .map((s) => s.length))) !== null && _b !== void 0 ? _b : columns);
    console.log([border, faros, border, READY_MSG, border].join('\n'));
}
if (require.main === module) {
    main();
}
