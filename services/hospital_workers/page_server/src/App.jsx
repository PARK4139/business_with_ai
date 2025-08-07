import React from 'react'
import './App.css'

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>병원 근무자 관리 시스템</h1>
        <p>Hospital Workers Management System</p>
      </header>
      <main>
        <div className="container">
          <h2>서비스 상태</h2>
          <div className="status-grid">
            <div className="status-item">
              <h3>API Server</h3>
              <p>✅ 정상 운영 중</p>
            </div>
            <div className="status-item">
              <h3>Database</h3>
              <p>✅ 연결됨</p>
            </div>
            <div className="status-item">
              <h3>Redis</h3>
              <p>✅ 연결됨</p>
            </div>
            <div className="status-item">
              <h3>Nginx</h3>
              <p>✅ 프록시 정상</p>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}

export default App
