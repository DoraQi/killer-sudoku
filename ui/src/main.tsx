import React from 'react'
import ReactDOM from 'react-dom/client'
import './index.css'
import App from './App'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <div className='background' />
    <div className='overlay'>
      <App />
    </div>
  </React.StrictMode>,
)
