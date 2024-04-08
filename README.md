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
# Not using Windows?
add a [maker](https://www.electronforge.io/config/makers) to package.json dev dependencies for the specific platform you want build with
