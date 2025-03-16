import React, { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { assign } from '../../store/slices/universalSlice';

function DesktopApp() {
  const universal = useSelector(state => state.universal);
  const goodbye = useSelector(state => state.universal?.goodbye?.friends);
  console.log('goodbye', goodbye)
  console.log(universal);

  const dispatch = useDispatch();

  useEffect(() => {
    if (!universal.hello) {
      dispatch(assign({hello: "Hello World"}))
      const testArr = ['hello', 'world'];
      dispatch(assign({testArr}))
      dispatch(assign({slices: {}}))
      dispatch(assign({slices: {Home: {}}}))
    }
  }, [])

  return (
    <div>DesktopApp</div>
  )
}

export default DesktopApp