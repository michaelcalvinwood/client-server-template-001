import React from 'react';
import { createRoot } from 'react-dom/client';
import { Provider } from 'react-redux';
import { store } from './store';
import MobileApp from './layouts/mobile/MobileApp';
import DesktopApp from './layouts/desktop/DesktopApp';

const container = document.getElementById('root');
const root = createRoot(container);
root.render(
  <React.StrictMode>
    <Provider store={store}>
      {/* <MobileApp /> */}
      <DesktopApp />
    </Provider>
  </React.StrictMode>
);
