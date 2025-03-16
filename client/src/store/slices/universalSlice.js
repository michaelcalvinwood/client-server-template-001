import { createSlice } from '@reduxjs/toolkit';
import lodash from 'lodash';

const initialState = {

};

export const universalSlice = createSlice({
  name: 'universal',
  initialState,
  reducers: {
    assign: (state, action) => {
        lodash.merge(state, action.payload);
        return state;
    },
  },
});

export const { assign } = universalSlice.actions;
export default universalSlice.reducer;
