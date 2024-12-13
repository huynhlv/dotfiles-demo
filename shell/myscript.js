const execSync = require('child_process').execSync;
const execOptions = { encoding: 'utf-8' }
function execCustom(shell, options = execOptions) {
	return execSync(shell, options)
}
execCustom('git branch --show-current', { stdio: 'inherit' })
