export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <div className="z-10 max-w-5xl w-full items-center justify-between font-mono text-sm lg:flex">
        <h1 className="text-4xl font-bold text-center mb-8">
          병원 근무자 관리 시스템
        </h1>
        <p className="text-center text-lg mb-4">
          HealBase 병원 직원용 관리 시스템에 오신 것을 환영합니다
        </p>
        <div className="flex gap-4 justify-center">
          <a 
            href="/heal_base_hospital_worker/v1/page/ensure/login"
            className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
          >
            로그인
          </a>
          <a 
            href="/heal_base_hospital_worker/v1/page/ensure/signup"
            className="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded"
          >
            회원가입
          </a>
        </div>
      </div>
    </main>
  )
}
