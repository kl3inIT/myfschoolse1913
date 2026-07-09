import { zodResolver } from '@hookform/resolvers/zod'
import { useNavigate } from '@tanstack/react-router'
import { Loader2, LockKeyhole, Phone } from 'lucide-react'
import { useForm } from 'react-hook-form'
import { toast } from 'sonner'
import { z } from 'zod'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { login, storeSession } from '@/lib/api'

const loginSchema = z.object({
  phoneNumber: z.string().trim().min(1, 'Vui lòng nhập số điện thoại'),
  password: z.string().min(8, 'Mật khẩu tối thiểu 8 ký tự'),
})

type LoginForm = z.infer<typeof loginSchema>

export function LoginPage() {
  const navigate = useNavigate()
  const form = useForm<LoginForm>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      phoneNumber: '0900000000',
      password: 'Password123',
    },
  })

  async function submit(values: LoginForm) {
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

  return (
    <main className="flex min-h-svh items-center justify-center bg-background p-4">
      <section className="w-full max-w-md space-y-4">
        <div className="space-y-3 text-center">
          <Badge variant="outline">MyFSchool quản trị</Badge>
          <div className="space-y-1">
            <h1 className="text-2xl font-semibold tracking-tight">
              Bảng quản trị
            </h1>
            <p className="text-sm text-muted-foreground">
              Đăng nhập để nhập và quản lý tài khoản học sinh.
            </p>
          </div>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Đăng nhập quản trị</CardTitle>
            <CardDescription>
              Tài khoản demo: 0900000000 / Password123 khi bật dữ liệu mẫu.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Form {...form}>
              <form
                onSubmit={form.handleSubmit(submit)}
                className="space-y-5"
                noValidate
              >
                <FormField
                  control={form.control}
                  name="phoneNumber"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Số điện thoại</FormLabel>
                      <div className="relative">
                        <Phone className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                        <FormControl>
                          <Input
                            autoComplete="username"
                            className="pl-9"
                            {...field}
                          />
                        </FormControl>
                      </div>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="password"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Mật khẩu</FormLabel>
                      <div className="relative">
                        <LockKeyhole className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                        <FormControl>
                          <Input
                            type="password"
                            autoComplete="current-password"
                            className="pl-9"
                            {...field}
                          />
                        </FormControl>
                      </div>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <Button
                  type="submit"
                  className="w-full"
                  disabled={form.formState.isSubmitting}
                >
                  {form.formState.isSubmitting ? (
                    <Loader2 className="size-4 animate-spin" />
                  ) : null}
                  Vào trang quản trị
                </Button>
              </form>
            </Form>
          </CardContent>
        </Card>
      </section>
    </main>
  )
}
