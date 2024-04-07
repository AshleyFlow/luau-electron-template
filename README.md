# Lune Electron
this template uses the [electron-lune-bindings](https://www.npmjs.com/package/electron-lune-bindings) package to connect lune to electron

---
# Instructions
Install all the dependencies with a package manager like pnpm or yarn (I used yarn)
Make sure to have Lune installed on your system ([Installation Guide](https://lune-org.github.io/docs/getting-started/1-installation))

## Examples
```shell
$ yarn install
```
```shell
$ pnpm install
```

---
## Scripts
Use the `dev` script to run the app in dev mod
In dev mode app will reload when a luau file changes in the project

Use the `make` script to make a windows installer

## Examples
```shell
$ yarn run dev
```
```shell
$ pnpm run dev
```

---
## Not using Windows?
For other platforms, first you might want to change what executable file `main.ts` uses to run luau code in production (by default it looks for a .exe file)

the executable file gets created automatically when you run the `dev` or `make` script (these scripts run build.luau using lune to build the executable)

then add a [maker](https://www.electronforge.io/config/makers) dependency for any platform you want to the project
