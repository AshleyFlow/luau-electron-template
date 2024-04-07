# Lune Electron
this template uses the [electron-lune-bindings](https://www.npmjs.com/package/electron-lune-bindings) package to connect lune to electron

---
# Setup
Install all the dependencies with a package manager like pnpm or yarn (I used yarn), also make sure to have Lune installed on your system ([Lune Installation Guide](https://lune-org.github.io/docs/getting-started/1-installation))

## Examples
```shell
$ yarn install
```
```shell
$ pnpm install
```

---
# Scripts
Use the `dev` script to run the app in dev mod, in dev mode app will reload when a luau file changes in the project

Use the `make` script to make a windows installer

## Examples
```shell
$ yarn run dev
```
```shell
$ pnpm run dev
```
---
# Issues
If you plan on making a custom folder and requiring modules from it, please add it as an alias to the .luaurc file, or else the `require` function would error in production.

---
# Not using Windows?
In dev mode the app should work fine on other platforms, but for the packaged version you might need to change what executable file `main.ts` uses to run luau code in production (by default it looks for a .exe file)

the executable file gets created automatically when you run the `dev` or `make` script (these scripts run build.luau using lune to build the executable)

then add a [maker](https://www.electronforge.io/config/makers) dependency for any platform you want to the project
