

let socket = null;
let theStore = null;

const dispatch = async (type, payload, store) => {
    console.log('socket dispatch', type, payload)
    store.dispatch({
        type, payload
    })
}

const handleTruthfulQaQuestions = async (data, store) => dispatch('truthfulQa/truthfulQaSetQuestions', data, store)
const handleResponseMessage = async (data, store) => dispatch('app/appAddResponse', data, store);
const handleCategoryMessage = async (data, store) => dispatch('app/appAddCategoryResponse', data, store);

export const setupTheSocket = (socketio, url, store) => {
    if (socket) return;
    socket = socketio(url);
    theStore = store;
    socket.on('message', message => {
        appMerge(store, {message});

        setTimeout(() => appMerge(store, {message: ''}), 1000)
    });

}

export const emit = (event, ...args) => {
    console.log('socket emit', event, ...args);
    socket.emit(event, ...args);
}