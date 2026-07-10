import { zodResolver } from '@hookform/resolvers/zod'
import {
  keepPreviousData,
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query'
import { useMemo, useState } from 'react'
import { useForm } from 'react-hook-form'
import { toast } from 'sonner'
import { z } from 'zod'
import { Bell, Loader2, Send } from 'lucide-react'
import { DataTable, DataTablePagination } from '@/components/data-table'
import { notificationColumns } from './columns'
import { Button } from '@/components/ui/button'
import { Checkbox } from '@/components/ui/checkbox'
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import {
  Empty,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from '@/components/ui/empty'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Textarea } from '@/components/ui/textarea'
import {
  deactivateNotification,
  fetchNotifications,
  notificationAudienceLabels,
  notificationCategoryLabels,
  publishNotification,
  type AdminNotification,
} from '@/lib/notifications'

const pageSize = 20

const publishSchema = z.object({
  title: z.string().trim().min(1, 'Vui lòng nhập tiêu đề').max(160, 'Tiêu đề tối đa 160 ký tự'),
  body: z.string().trim().min(1, 'Vui lòng nhập nội dung').max(1000, 'Nội dung tối đa 1000 ký tự'),
  category: z.enum(['ACADEMIC', 'EVENT', 'SERVICE', 'GENERAL']),
  audience: z.enum(['ALL_STUDENTS', 'HIGH_SCHOOL']),
  pinned: z.boolean(),
})

type PublishForm = z.infer<typeof publishSchema>

export function NotificationManagementPage() {
  const [page, setPage] = useState(0)
  const queryClient = useQueryClient()

  const notificationsQuery = useQuery({
    queryKey: ['admin-notifications', 'list', page],
    queryFn: () => fetchNotifications({ page, size: pageSize }),
    placeholderData: keepPreviousData,
  })

  const deactivateMutation = useMutation({
    mutationFn: deactivateNotification,
    onSuccess: () => {
      toast.success('Đã thu hồi thông báo')
      queryClient.invalidateQueries({ queryKey: ['admin-notifications'] })
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Thu hồi thông báo thất bại',
      )
    },
  })

  return (
    <div className="flex h-[calc(100svh-8rem)] flex-col gap-4">
      <section className="flex items-center justify-end">
        <PublishNotificationDialog />
      </section>

      <section className="flex min-h-0 min-w-0 flex-1 flex-col">
        <NotificationListPanel
          isLoading={notificationsQuery.isPending}
          page={page}
          result={notificationsQuery.data}
          deactivatingId={
            deactivateMutation.isPending
              ? deactivateMutation.variables
              : undefined
          }
          onDeactivate={(notification) =>
            deactivateMutation.mutate(notification.id)
          }
          onPageChange={setPage}
        />

      </section>
    </div>
  )
}

function PublishNotificationDialog() {
  const [open, setOpen] = useState(false)
  const queryClient = useQueryClient()

  const form = useForm<PublishForm>({
    resolver: zodResolver(publishSchema),
    defaultValues: {
      title: '',
      body: '',
      category: 'GENERAL',
      audience: 'ALL_STUDENTS',
      pinned: false,
    },
  })

  const publishMutation = useMutation({
    mutationFn: publishNotification,
    onSuccess: (notification) => {
      toast.success(`Đã đăng thông báo "${notification.title}"`)
      form.reset()
      queryClient.invalidateQueries({ queryKey: ['admin-notifications'] })
      setOpen(false)
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Đăng thông báo thất bại',
      )
    },
  })

  function changeOpen(nextOpen: boolean) {
    setOpen(nextOpen)
    if (nextOpen) {
      form.reset()
    }
  }

  return (
    <Dialog open={open} onOpenChange={changeOpen}>
      <DialogTrigger asChild>
        <Button type="button">
          <Send className="size-4" />
          Đăng thông báo
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>Đăng thông báo mới</DialogTitle>
          <DialogDescription>
            Thông báo hiển thị ngay trong app học sinh sau khi đăng.
          </DialogDescription>
        </DialogHeader>

        <Form {...form}>
          <form
            id="publish-notification-form"
            onSubmit={form.handleSubmit((values) =>
              publishMutation.mutate(values),
            )}
            className="space-y-4"
            noValidate
          >
                <FormField
                  control={form.control}
                  name="title"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Tiêu đề</FormLabel>
                      <FormControl>
                        <Input
                          autoComplete="off"
                          placeholder="VD: Lịch nghỉ lễ Quốc khánh"
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="body"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Nội dung</FormLabel>
                      <FormControl>
                        <Textarea
                          className="min-h-28 resize-y"
                          placeholder="Nội dung chi tiết gửi tới học sinh"
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <div className="grid gap-4 sm:grid-cols-2">
                  <FormField
                    control={form.control}
                    name="category"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Phân loại</FormLabel>
                        <Select
                          value={field.value}
                          onValueChange={field.onChange}
                        >
                          <FormControl>
                            <SelectTrigger className="w-full">
                              <SelectValue />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            {Object.entries(notificationCategoryLabels).map(
                              ([value, label]) => (
                                <SelectItem key={value} value={value}>
                                  {label}
                                </SelectItem>
                              ),
                            )}
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="audience"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Đối tượng nhận</FormLabel>
                        <Select
                          value={field.value}
                          onValueChange={field.onChange}
                        >
                          <FormControl>
                            <SelectTrigger className="w-full">
                              <SelectValue />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            {Object.entries(notificationAudienceLabels).map(
                              ([value, label]) => (
                                <SelectItem key={value} value={value}>
                                  {label}
                                </SelectItem>
                              ),
                            )}
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>

                <FormField
                  control={form.control}
                  name="pinned"
                  render={({ field }) => (
                    <FormItem className="flex flex-row items-center gap-2 space-y-0">
                      <FormControl>
                        <Checkbox
                          checked={field.value}
                          onCheckedChange={(checked) =>
                            field.onChange(checked === true)
                          }
                        />
                      </FormControl>
                      <FormLabel className="font-normal">
                        Ghim lên đầu danh sách của học sinh
                      </FormLabel>
                    </FormItem>
                  )}
                />
          </form>
        </Form>

        <DialogFooter>
          <DialogClose asChild>
            <Button type="button" variant="outline">
              Hủy
            </Button>
          </DialogClose>
          <Button
            type="submit"
            form="publish-notification-form"
            disabled={publishMutation.isPending}
          >
            {publishMutation.isPending ? (
              <Loader2 className="size-4 animate-spin" />
            ) : (
              <Send className="size-4" />
            )}
            Đăng thông báo
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

function NotificationListPanel({
  isLoading,
  page,
  result,
  deactivatingId,
  onDeactivate,
  onPageChange,
}: {
  isLoading: boolean
  page: number
  result?: {
    totalItems: number
    totalPages: number
    items: AdminNotification[]
  }
  deactivatingId?: string
  onDeactivate: (notification: AdminNotification) => void
  onPageChange: (page: number) => void
}) {
  const notifications = result?.items ?? []
  const columns = useMemo(
    () => notificationColumns({ deactivatingId, onDeactivate }),
    [deactivatingId, onDeactivate],
  )

  return (
    <div className="flex min-h-0 min-w-0 flex-1 flex-col rounded-md border bg-background">
      <div className="min-h-0 flex-1 overflow-auto">
        <DataTable
          columns={columns}
          data={notifications}
          isLoading={isLoading}
          empty={
            <Empty className="min-h-[360px] border-0">
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <Bell />
                </EmptyMedia>
                <EmptyTitle>Chưa có thông báo</EmptyTitle>
                <EmptyDescription>
                  Bấm "Đăng thông báo" để đăng thông báo đầu tiên.
                </EmptyDescription>
              </EmptyHeader>
            </Empty>
          }
        />
      </div>

      <DataTablePagination
        page={page}
        totalPages={result?.totalPages ?? 0}
        totalItems={result?.totalItems ?? 0}
        unitLabel="thông báo"
        onPageChange={onPageChange}
      />
    </div>
  )
}
