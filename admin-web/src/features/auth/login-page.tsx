import { GraduationCap } from 'lucide-react'
import { LoginForm } from '@/components/login-form'

export function LoginPage() {
  return (
    <div className="flex min-h-svh w-full flex-col items-center justify-center gap-6 bg-background p-6 md:p-10">
      <div className="flex w-full max-w-sm flex-col gap-6">
        <div className="flex items-center justify-center gap-2 font-medium">
          <div className="flex size-6 items-center justify-center rounded-md bg-primary text-primary-foreground">
            <GraduationCap className="size-4" />
          </div>
          MyFSchool — Bảng quản trị
        </div>
        <LoginForm />
      </div>
    </div>
  )
}
