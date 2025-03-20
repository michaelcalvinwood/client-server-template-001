

let socket = null;
let theStore = null;

export const setupTheSocket = (socketio, url, store) => {
    if (socket) return;
    socket = socketio(url);
    theStore = store;
    socket.on('redux', (payload, type) => {
        store.dispatch({type, payload})
    });

}

export const emit = (event, ...args) => {
    console.log('socket emit', event, ...args);
    socket.emit(event, ...args);
}