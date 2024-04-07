import { IpcRendererEvent } from "electron";

export {};

declare global {
  interface Window {
    ipc: {
      send: (channel: string, ...args: any[]) => void;
      sendToLune: (channel: string, value: any) => void;
      on: (
        channel: string,
        listener: (event: IpcRendererEvent, ...args: any[]) => void
      ) => void;
    };
  }
}
