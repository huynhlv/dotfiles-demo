const execSync = require('child_process').execSync;
const execOptions = { encoding: 'utf-8' }
function execCustom(shell, options = execOptions) {
	return execSync(shell, options)
}

let args = process.argv.slice(2);

const PREFIXES = ['fix', 'feat', 'pick', 'chore']

const AMEND_OPTION = '--amend'

const VERIFY_OPTION = '-n'

const OL_TICKET = 'OL-'

const argIndex = (options) => {
	return args.findIndex((val) => options.includes(val) || val.includes(options))
}

let shellOptions = ''
let prefix = ''
let ticketOL = ''

const currentBranch = execCustom('git branch --show-current').trim().split('/')

if (PREFIXES.includes(currentBranch[0])) {
	prefix = currentBranch[0]
}

const indexPrefix = argIndex(PREFIXES)
if (indexPrefix > -1) {
	prefix = args.splice(indexPrefix, 1).pop()
}

let isAmend = false

args = args.reduce((args, element) => {
	const option = element.slice(0,2).includes('-')
	if (option) {
		if (element === AMEND_OPTION) {
			isAmend = true
		}
		shellOptions += ` ${element}`
	} else {
		args.push(element)
	}
	return args
}, []);

if (currentBranch[1].includes(OL_TICKET)) {
	ticketOL = OL_TICKET + currentBranch[1].split(OL_TICKET)[1].slice(0,6)
}

const ticketIndex = argIndex(OL_TICKET)
if (ticketIndex > -1) {
	const ticketUrl = args.splice(ticketIndex, 1).pop()
	ticketOL = OL_TICKET + ticketUrl.split(OL_TICKET)[1]
}

let commitName = args.splice(0, 1).pop() || ''
commitName = commitName.charAt(0).toLowerCase() + commitName.slice(1)
if (prefix === 'chore') {
	commitName = `chore(): ${commitName}`
} else {
	commitName = `${prefix}(${ticketOL}): ${commitName}`
}

if (args.length === 0) {
	if (isAmend) {
		execCustom(`git commit ${shellOptions}`, { stdio: 'inherit' })
	} else {
		if (commitName.length <= 100) {
			execCustom(`git commit -m "${commitName}" ${shellOptions}`, { stdio: 'inherit' })
		} else {
			console.log(`Commit length should be less than 100, current: ${commitName.length}`)
		}
	}
}
