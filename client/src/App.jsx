import React, { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { assign } from './store/slices/universalSlice'
import DesktopApp from './layouts/desktop/DesktopApp';
import TabletApp from './layouts/tablet/TabletApp';
import MobileApp from './layouts/mobile/MobileApp';

/**
 * App selects which layout will be used based on window width: Desktop, Tablet, Mobile
 */

function App() {
    const dispatch = useDispatch();
    let dimensions = useSelector(state => state?.universal?.slice?.dimensions) || {height: 0, width: 0};

    let layout = '';
    if (dimensions.width >= 1024) layout = 'desktop';
    else if (dimensions.width >= 600) layout = 'tablet';
    else layout = 'mobile';

    const setDimensions = () => {
        const width = window.innerWidth;
        const height = window.innerHeight;
    
        dispatch(assign({slice: {dimensions: {width, height}}}))
    }

    useEffect(() => {
        window.addEventListener('resize', setDimensions)
        setDimensions();
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