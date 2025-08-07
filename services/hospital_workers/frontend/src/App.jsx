import { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="App">
      <header className="App-header">
        <h1>병원 근무자 관리 시스템</h1>
        <p>개발 모드 - Hot Reload 테스트 (bash 환경에서 수정됨!)</p>
        <div className="card">
          <button onClick={() => setCount((count) => count + 1)}>
            카운트: {count}
          </button>
          <p>
            이 버튼을 클릭하면 카운트가 증가합니다. 개발 모드에서는 코드 변경 시 자동으로 새로고침됩니다.
          </p>
        </div>
      </header>
    </div>
  )
}

export default App
