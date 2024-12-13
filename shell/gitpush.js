const execSync = require('child_process').execSync;

const fs = require('fs');
let baseBranch = ''

try {
	const folder = '/home/huynh/Dev/subline-text/bashjs/soucebase.txt'
	const data = fs.readFileSync(folder, { encoding: 'utf8', flag: 'r' });
	baseBranch = data.toString().trim().split('=')[1];
} catch(e) {
	console.log('Error:', e);
}
function execCustom(shell) {
	return execSync(shell, { encoding: 'utf-8' })
}

let args = process.argv.slice(2);

const PREFIXES = ['fix', 'feat', 'pick']
const foldername = execCustom('basename "$PWD"').trim()
const gitUrl = `https://github.com/ParadoxAi/${foldername}/compare`
const FgGreen = "\x1b[32m"

const AMEND_OPTION = '--amend'

const VERIFY_OPTION = '-n'

const OL_TICKET = 'OL-'

const argIndex = (options) => {
	return args.findIndex((val) => options.includes(val))
}

let shellOptions = ''
let ticketOL = ''

const fullBranch = execCustom('git branch --show-current').trim()
const currentBranch = execCustom('git branch --show-current').trim().split('/')

if (currentBranch[1].includes(OL_TICKET)) {
	ticketOL = OL_TICKET + currentBranch[1].split(OL_TICKET)[1].slice(0,6)
}

args = args.reduce((args, element) => {
	const option = element.slice(0,2).includes('-')
	if (option) {
		shellOptions += ` ${element}`
	} else {
		args.push(element)
	}
	return args
}, []);

execCustom(`git push origin ${fullBranch} ${shellOptions}`).trim()

if (ticketOL) {
	console.log(`${FgGreen}Jira: https://paradoxai.atlassian.net/browse/${ticketOL}`)
}
console.log(`URL: ${gitUrl}/${baseBranch}...${fullBranch}?expand=1`);
