import React from 'react';
import { createRoot } from 'react-dom/client';
import { Provider } from 'react-redux';
import { store } from './store';
import MobileApp from './layouts/mobile/MobileApp';

const container = document.getElementById('root');
const root = createRoot(container!);
root.render(
  <React.StrictMode>
    <Provider store={store}>
      <MobileApp />
    </Provider>
  </React.StrictMode>
);
