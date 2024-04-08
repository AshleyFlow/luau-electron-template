# Lune Electron
this template uses the [electron-lune-bindings](https://www.npmjs.com/package/electron-lune-bindings) package to connect lune to electron

---
# CREATE-LUAU-APP
project generator: https://github.com/HighFlowey/create-luau-app

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
# Not using Windows?
Add a [maker](https://www.electronforge.io/config/makers) to package.json dev dependencies for the specific platform you want build with

---
# Creating packages
Create an empty project with yarn or npm, then add [npmluau](https://github.com/seaofvoices/npmluau/) and [luau-electron-bindings](https://github.com/HighFlowey/luau-electron-bindings) to package.json's dependencies

Using `require("@pkg/luau-electron-bindings").app` you can now create elements in your new project, to see the elements you have to add your new project as a dependency to your lune-electron project ofcourse.
