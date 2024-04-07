// setup a bridge between electron and vanilla js
import { IpcRendererEvent } from "electron";
import { contextBridge, ipcRenderer } from "electron";

contextBridge.exposeInMainWorld("ipc", {
  send: (channel: string, ...args: any[]) => ipcRenderer.send(channel, ...args),
  sendToLune: (channel: string, value: string) =>
    ipcRenderer.send("toLune", channel, value),
  on: (
    channel: string,
    listener: (event: IpcRendererEvent, ...args: any[]) => void
  ) => ipcRenderer.on(channel, listener),
});
