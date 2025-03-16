import { configureStore } from '@reduxjs/toolkit';
import counterReducer from './slices/counterSlice.js';
import universalReducer from './slices/universalSlice.js';

export const store = configureStore({
  reducer: {
    universal: universalReducer,
    counter: counterReducer,
  },
});
