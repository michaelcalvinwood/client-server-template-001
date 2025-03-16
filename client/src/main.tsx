import React from 'react';
import { createRoot } from 'react-dom/client';
import MobileApp from './layouts/mobile/MobileApp';

const container = document.getElementById('root');
const root = createRoot(container!);
root.render(
  <React.StrictMode>
    <MobileApp />
  </React.StrictMode>
);