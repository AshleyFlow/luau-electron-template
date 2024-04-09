const allowRules = {
    ifStartsWith: ["/node_modules", "/dist", "/.luaurc"],
    ifEndsWith: [],
}

const importantIgnoreRules = {
    ifStartsWith: [],
    ifEndsWith: [".ts", ".md"],
}

const ignoreRules = {
    ifStartsWith: ["/."],
    ifEndsWith: [".luau"],
}

function runRules(rules, callback) {
    let passed = false
    rules.some(rule => {
        if (callback(rule)) {
            passed = true
            return true
        }

        return false
    })
    return passed
}

module.exports = {
    packagerConfig: {
        ignore: (file) => {
            let importantIgnore = false;

            importantIgnore = runRules(importantIgnoreRules.ifStartsWith, (rule) => file.startsWith(rule))

            if (importantIgnore) return true;

            importantIgnore = runRules(importantIgnoreRules.ifEndsWith, (rule) => file.endsWith(rule))

            if (importantIgnore) return true;

            let allow = false;

            allow = runRules(allowRules.ifStartsWith, (rule) => file.startsWith(rule))

            if (allow) return false;

            allow = runRules(allowRules.ifEndsWith, (rule) => file.endsWith(rule))

            if (allow) return false;

            let ignore = false;

            ignore = runRules(ignoreRules.ifStartsWith, (rule) => file.startsWith(rule))

            if (ignore) return true;

            ignore = runRules(ignoreRules.ifEndsWith, (rule) => file.endsWith(rule))

            return ignore;
        },
    },
    makers: [
        {
            name: "@electron-forge/maker-squirrel",
            config: {
                name: "lune-electron"
            }
        }
    ]
}