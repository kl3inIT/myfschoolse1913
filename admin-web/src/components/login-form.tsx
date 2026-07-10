import { zodResolver } from '@hookform/resolvers/zod'
import { useNavigate } from '@tanstack/react-router'
import { Loader2 } from 'lucide-react'
import { useForm } from 'react-hook-form'
import { toast } from 'sonner'
import { z } from 'zod'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import {
  Field,
  FieldDescription,
  FieldError,
  FieldGroup,
  FieldLabel,
} from '@/components/ui/field'
import { Input } from '@/components/ui/input'
import { login, storeSession } from '@/lib/api'

const loginSchema = z.object({
  phoneNumber: z.string().trim().min(1, 'Vui lòng nhập số điện thoại'),
  password: z.string().min(8, 'Mật khẩu tối thiểu 8 ký tự'),
})

type LoginFormValues = z.infer<typeof loginSchema>

export function LoginForm({
  className,
  ...props
}: React.ComponentProps<'div'>) {
  const navigate = useNavigate()
  const form = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      phoneNumber: '0900000000',
      password: 'Password123',
    },
  })

  async function submit(values: LoginFormValues) {
    try {
      const session = await login(values.phoneNumber, values.password)
      if (session.user.role !== 'ADMIN') {
        toast.error('Tài khoản này không có quyền quản trị')
        return
      }

      storeSession(session)
      toast.success('Đăng nhập quản trị thành công')
      await navigate({ to: '/' })
    } catch (error) {
      toast.error(error instanceof Error ? error.message : 'Đăng nhập thất bại')
    }
  }

  const { errors, isSubmitting } = form.formState

  return (
    <div className={cn('flex flex-col gap-6', className)} {...props}>
      <Card>
        <CardHeader>
          <CardTitle>Đăng nhập quản trị</CardTitle>
          <CardDescription>
            Dùng tài khoản quản trị của trường để vào bảng điều khiển.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(submit)} noValidate>
            <FieldGroup>
              <Field data-invalid={errors.phoneNumber ? true : undefined}>
                <FieldLabel htmlFor="phoneNumber">Số điện thoại</FieldLabel>
                <Input
                  id="phoneNumber"
                  type="tel"
                  autoComplete="username"
                  aria-invalid={errors.phoneNumber ? true : undefined}
                  {...form.register('phoneNumber')}
                />
                <FieldError errors={[errors.phoneNumber]} />
              </Field>
              <Field data-invalid={errors.password ? true : undefined}>
                <FieldLabel htmlFor="password">Mật khẩu</FieldLabel>
                <Input
                  id="password"
                  type="password"
                  autoComplete="current-password"
                  aria-invalid={errors.password ? true : undefined}
                  {...form.register('password')}
                />
                <FieldError errors={[errors.password]} />
              </Field>
              <Field>
                <Button type="submit" disabled={isSubmitting}>
                  {isSubmitting ? (
                    <Loader2 className="size-4 animate-spin" />
                  ) : null}
                  Vào trang quản trị
                </Button>
                <FieldDescription className="text-center">
                  Tài khoản demo: 0900000000 / Password123 khi bật dữ liệu mẫu.
                </FieldDescription>
              </Field>
            </FieldGroup>
          </form>
        </CardContent>
      </Card>
    </div>
  )
}
