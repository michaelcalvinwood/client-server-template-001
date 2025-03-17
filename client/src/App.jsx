import React, { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { assign } from './store/slices/universalSlice'
import DesktopApp from './layouts/desktop/DesktopApp';
import TabletApp from './layouts/tablet/TabletApp';
import MobileApp from './layouts/mobile/MobileApp';
import appConfig from '../appConfig.json';

import { store } from './store/index';
import { io } from 'socket.io-client';
import * as socketService from './socketService';

/**
 * App selects which layout will be used based on window width: Desktop, Tablet, Mobile
 */

function App() {
    const dispatch = useDispatch();
    let dimensions = useSelector(state => state?.universal?.slice?.dimensions) || {height: 0, width: 0};

    let layout = '';
    if (dimensions.width >= appConfig.desktopBreakpoint) layout = 'desktop';
    else if (dimensions.width >= appConfig.tabletBreakpoint) layout = 'tablet';
    else layout = 'mobile';

    const setDimensions = () => {
        const width = window.innerWidth;
        const height = window.innerHeight;
    
        dispatch(assign({slice: {dimensions: {width, height}}}))
    }

    useEffect(() => {
        window.addEventListener('resize', setDimensions)
        setDimensions();

        const url = appConfig.proto + appConfig.host + ":" + appConfig.port;
        console.log("Socket URL", url)
        socketService.setupTheSocket(io, url, store);
    }, [])
  return (
    <div className='App'>
        {layout === 'desktop' && <DesktopApp />}
        {layout === 'tablet' && <TabletApp />}
        {layout === 'mobile' && <MobileApp />}
    </div>
  )
}

export default App