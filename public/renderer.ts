/// <reference path="../types/ipc.d.ts" />
let elements: {
  [id: number]: Element;
} = {};

let events: {
  [id: number]: {
    [event: string]: number[];
  };
};

function getElementId(element: Element | null) {
  for (const [i, v] of Object.entries(elements)) {
    if (element === v) {
      return Number(i);
    }
  }
}

function getElementById(id: number) {
  for (const [i, v] of Object.entries(elements)) {
    if (id === Number(i)) {
      return v;
    }
  }
}

window.ipc.on("ready", () => {
  console.log("Lune loaded");
});

window.ipc.on(
  "invoke:querySelector",
  (_, info: { eventId: number; selector: string }) => {
    let reservedId = Object.keys(elements).length + 1;

    let element = document.querySelector(info.selector);
    let id: number | undefined = getElementId(element);

    if (!id && element) {
      elements[reservedId - 1] = element;
      id = reservedId;
    }

    window.ipc.sendToLune("invoke:" + info.eventId, {
      id,
      selector: info.selector,
    });
  }
);

window.ipc.on(
  "invoke:createElement",
  (_, info: { eventId: number; tagName: string; innerHTML?: string }) => {
    let reservedId = Object.keys(elements).length + 1;

    let element = document.createElement(info.tagName);
    let id: number;

    if (info.innerHTML) element.innerHTML = info.innerHTML;
    document.body.appendChild(element);

    elements[reservedId - 1] = element;
    id = reservedId;

    window.ipc.sendToLune("invoke:" + info.eventId, {
      id,
      tagName: info.tagName,
    });
  }
);

window.ipc.on("setProperty", (_, info: { id: number; k: string; v: any }) => {
  let element = elements[info.id - 1];

  if (info.k === "parent") {
    if (info.v === "null") {
      (element as HTMLElement).style.visibility = "hidden";
    } else {
      let parent = elements[Number(info.v) - 1];
      parent.appendChild(element);
      (element as HTMLElement).style.visibility = "visible";
    }
  } else if (element) {
    (element as any)[info.k] = info.v;
  }
});

window.ipc.on(
  "setNestedProperties",
  (_, info: { id: number; k: string; v: { [key: string]: any } }) => {
    let element = elements[info.id - 1];

    function apply(el: any, k: any, v: any) {
      if (typeof v === "object") {
        Object.keys(v).forEach((k) => {
          apply(el[k], k, v[k]);
        });
      } else {
        el[k] = v;
      }
    }

    Object.keys(info.v).forEach((k) => {
      apply((element as any)[info.k], k, info.v[k]);
    });
  }
);

window.ipc.on(
  "setEvent",
  (_, info: { id: number; event: string; eventId: number }) => {
    let element = elements[info.id - 1];

    if (!events[info.id]) {
      events[info.id] = {};
    }

    if (!events[info.id][info.event]) {
      events[info.id][info.event] = [];
    }

    events[info.id][info.event].push(info.eventId);

    (element as any)[info.event] = function () {
      events[info.id][info.event].forEach((eventId) => {
        window.ipc.sendToLune("event:" + eventId, {});
      });
    };
  }
);

window.ipc.on(
  "disconnectEvent",
  (_, info: { id: number; event: string; eventId: number }) => {
    if (!events[info.id]) return;
    if (!events[info.id][info.event]) return;

    events[info.id][info.event] = events[info.id][info.event].filter(
      (eventId) => {
        return eventId == info.eventId ? null : eventId;
      }
    );
  }
);

window.ipc.on("refresh", () => {
  location.reload();
});

window.addEventListener("DOMContentLoaded", () => {
  events = [];
  elements = [];
  window.ipc.send("load");
});
