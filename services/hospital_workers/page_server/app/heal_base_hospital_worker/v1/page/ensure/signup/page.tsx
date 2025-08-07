'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'

export default function SignupPage() {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    name: '',
    department: '',
    employeeId: ''
  })
  const router = useRouter()

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (formData.password !== formData.confirmPassword) {
      alert('비밀번호가 일치하지 않습니다.')
      return
    }

    try {
      const response = await fetch('/heal_base_hospital_worker/v1/api/ensure/signup/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: formData.email,
          password: formData.password,
          name: formData.name,
          department: formData.department,
          employee_id: formData.employeeId
        }),
      })

      if (response.ok) {
        router.push('/heal_base_hospital_worker/v1/page/ensure/signup-complete')
      } else {
        alert('회원가입에 실패했습니다.')
      }
    } catch (error) {
      console.error('Signup error:', error)
      alert('회원가입 중 오류가 발생했습니다.')
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            회원가입
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            HealBase 병원 직원 관리 시스템
          </p>
        </div>
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div className="rounded-md shadow-sm -space-y-px">
            <div>
              <input
                name="email"
                type="email"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="이메일"
                value={formData.email}
                onChange={handleChange}
              />
            </div>
            <div>
              <input
                name="name"
                type="text"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="이름"
                value={formData.name}
                onChange={handleChange}
              />
            </div>
            <div>
              <input
                name="employeeId"
                type="text"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="사원번호"
                value={formData.employeeId}
                onChange={handleChange}
              />
            </div>
            <div>
              <select
                name="department"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                value={formData.department}
                onChange={handleChange}
              >
                <option value="">부서 선택</option>
                <option value="내과">내과</option>
                <option value="외과">외과</option>
                <option value="소아과">소아과</option>
                <option value="산부인과">산부인과</option>
                <option value="정형외과">정형외과</option>
                <option value="신경과">신경과</option>
                <option value="피부과">피부과</option>
                <option value="안과">안과</option>
                <option value="이비인후과">이비인후과</option>
                <option value="정신건강의학과">정신건강의학과</option>
                <option value="응급의학과">응급의학과</option>
                <option value="진단방사선과">진단방사선과</option>
                <option value="임상병리과">임상병리과</option>
                <option value="약제과">약제과</option>
                <option value="간호부">간호부</option>
                <option value="행정과">행정과</option>
              </select>
            </div>
            <div>
              <input
                name="password"
                type="password"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="비밀번호"
                value={formData.password}
                onChange={handleChange}
              />
            </div>
            <div>
              <input
                name="confirmPassword"
                type="password"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="비밀번호 확인"
                value={formData.confirmPassword}
                onChange={handleChange}
              />
            </div>
          </div>

          <div>
            <button
              type="submit"
              className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              회원가입
            </button>
          </div>

          <div className="text-center">
            <a href="/heal_base_hospital_worker/v1/page/ensure/login" className="font-medium text-indigo-600 hover:text-indigo-500">
              이미 계정이 있으신가요? 로그인
            </a>
          </div>
        </form>
      </div>
    </div>
  )
}
