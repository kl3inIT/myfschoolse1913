import {
  keepPreviousData,
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query'
import { useEffect, useMemo, useState } from 'react'
import { toast } from 'sonner'
import {
  Check,
  ClipboardList,
  Clock,
  Loader2,
  ThumbsDown,
  ThumbsUp,
  X,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { DataTable, DataTablePagination } from '@/components/data-table'
import { applicationColumns } from './columns'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  Empty,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from '@/components/ui/empty'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Skeleton } from '@/components/ui/skeleton'
import { Textarea } from '@/components/ui/textarea'
import {
  applicationStatusLabels,
  applicationTypeLabels,
  fetchApplications,
  fetchApplicationStats,
  reviewApplication,
  type AdminApplication,
  type AdminApplicationStats,
} from '@/lib/applications'

const pageSize = 20

type ReviewTarget = {
  application: AdminApplication
  decision: 'APPROVED' | 'REJECTED'
}

export function ApplicationManagementPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('PENDING')
  const [page, setPage] = useState(0)
  const [reviewTarget, setReviewTarget] = useState<ReviewTarget | null>(null)
  const [reviewerNote, setReviewerNote] = useState('')

  const queryClient = useQueryClient()

  useEffect(() => {
    const handle = setTimeout(() => {
      setDebouncedSearch(searchTerm.trim())
      setPage(0)
    }, 300)
    return () => clearTimeout(handle)
  }, [searchTerm])

  const statusParam = statusFilter === 'ALL' ? '' : statusFilter

  const applicationsQuery = useQuery({
    queryKey: ['admin-applications', 'list', debouncedSearch, statusParam, page],
    queryFn: () =>
      fetchApplications({
        search: debouncedSearch,
        status: statusParam,
        page,
        size: pageSize,
      }),
    placeholderData: keepPreviousData,
  })

  const statsQuery = useQuery({
    queryKey: ['admin-applications', 'stats'],
    queryFn: fetchApplicationStats,
  })

  const reviewMutation = useMutation({
    mutationFn: reviewApplication,
    onSuccess: (application) => {
      toast.success(
        application.status === 'APPROVED'
          ? `Đã duyệt đơn của ${application.fullName}`
          : `Đã từ chối đơn của ${application.fullName}`,
      )
      queryClient.invalidateQueries({ queryKey: ['admin-applications'] })
      setReviewTarget(null)
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Duyệt đơn thất bại',
      )
    },
  })

  const columns = useMemo(
    () =>
      applicationColumns({
        onReview: (application, decision) => {
          setReviewerNote('')
          setReviewTarget({ application, decision })
        },
      }),
    [],
  )

  const applications = applicationsQuery.data?.items ?? []

  function submitReview() {
    if (!reviewTarget) {
      return
    }
    reviewMutation.mutate({
      id: reviewTarget.application.id,
      decision: reviewTarget.decision,
      reviewerNote: reviewerNote.trim() || undefined,
    })
  }

  return (
    <div className="flex h-[calc(100svh-8rem)] flex-col gap-4">
      <StatsRow stats={statsQuery.data} isLoading={statsQuery.isPending} />

      <section className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex flex-wrap items-center gap-2">
          <Input
            aria-label="Tìm đơn từ"
            value={searchTerm}
            onChange={(event) => setSearchTerm(event.target.value)}
            placeholder="Tìm mã, tên học sinh, lớp, lý do"
            className="sm:w-72"
          />
          <Select
            value={statusFilter}
            onValueChange={(value) => {
              setStatusFilter(value)
              setPage(0)
            }}
          >
            <SelectTrigger aria-label="Lọc trạng thái" className="w-full sm:w-40">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="PENDING">
                {applicationStatusLabels.PENDING}
              </SelectItem>
              <SelectItem value="APPROVED">
                {applicationStatusLabels.APPROVED}
              </SelectItem>
              <SelectItem value="REJECTED">
                {applicationStatusLabels.REJECTED}
              </SelectItem>
              <SelectItem value="ALL">Tất cả</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </section>

      <section className="flex min-h-0 flex-1 flex-col">
        <div className="flex min-h-0 min-w-0 flex-1 flex-col rounded-md border bg-background">
          <div className="min-h-0 flex-1 overflow-auto">
            <DataTable
              columns={columns}
              data={applications}
              isLoading={applicationsQuery.isPending}
              empty={
                <Empty className="min-h-[360px] border-0">
                  <EmptyHeader>
                    <EmptyMedia variant="icon">
                      <ClipboardList />
                    </EmptyMedia>
                    <EmptyTitle>
                      {searchTerm
                        ? 'Không tìm thấy đơn từ'
                        : statusFilter === 'PENDING'
                          ? 'Không có đơn chờ duyệt'
                          : 'Chưa có đơn từ'}
                    </EmptyTitle>
                    <EmptyDescription>
                      {searchTerm
                        ? 'Thử từ khóa khác hoặc xóa ô tìm kiếm.'
                        : 'Đơn học sinh gửi từ app sẽ xuất hiện tại đây.'}
                    </EmptyDescription>
                  </EmptyHeader>
                </Empty>
              }
            />
          </div>

          <DataTablePagination
            page={page}
            totalPages={applicationsQuery.data?.totalPages ?? 0}
            totalItems={applicationsQuery.data?.totalItems ?? 0}
            unitLabel="đơn từ"
            onPageChange={setPage}
          />
        </div>
      </section>

      <ReviewDialog
        target={reviewTarget}
        reviewerNote={reviewerNote}
        isPending={reviewMutation.isPending}
        onReviewerNoteChange={setReviewerNote}
        onOpenChange={(open) => {
          if (!open) {
            setReviewTarget(null)
          }
        }}
        onSubmit={submitReview}
      />
    </div>
  )
}

function ReviewDialog({
  target,
  reviewerNote,
  isPending,
  onReviewerNoteChange,
  onOpenChange,
  onSubmit,
}: {
  target: ReviewTarget | null
  reviewerNote: string
  isPending: boolean
  onReviewerNoteChange: (value: string) => void
  onOpenChange: (open: boolean) => void
  onSubmit: () => void
}) {
  const approving = target?.decision === 'APPROVED'

  return (
    <Dialog open={target != null} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>
            {approving ? 'Duyệt đơn từ' : 'Từ chối đơn từ'}
          </DialogTitle>
          <DialogDescription>
            {target
              ? `${applicationTypeLabels[target.application.type]} — ${target.application.fullName} (${target.application.studentCode})`
              : ''}
          </DialogDescription>
        </DialogHeader>

        {target ? (
          <div className="space-y-4">
            <div className="rounded-md border bg-muted/40 p-3 text-sm">
              <p className="font-medium">{target.application.reason}</p>
              {target.application.details ? (
                <p className="mt-1 text-muted-foreground">
                  {target.application.details}
                </p>
              ) : null}
              <p className="mt-1 text-xs text-muted-foreground">
                Ngày áp dụng:{' '}
                {new Date(
                  `${target.application.targetDate}T00:00:00`,
                ).toLocaleDateString('vi-VN')}
                {target.application.requestedTime
                  ? ` · ${target.application.requestedTime.slice(0, 5)}`
                  : ''}
              </p>
            </div>

            <div className="space-y-2">
              <Label htmlFor="reviewerNote">Ghi chú duyệt (tùy chọn)</Label>
              <Textarea
                id="reviewerNote"
                value={reviewerNote}
                onChange={(event) => onReviewerNoteChange(event.target.value)}
                placeholder={
                  approving
                    ? 'VD: Nhớ bổ sung đơn giấy có chữ ký phụ huynh'
                    : 'VD: Lý do chưa đủ rõ, liên hệ giáo viên chủ nhiệm'
                }
                className="min-h-20 resize-y"
                maxLength={500}
              />
            </div>
          </div>
        ) : null}

        <DialogFooter>
          <Button
            type="button"
            variant="outline"
            onClick={() => onOpenChange(false)}
          >
            Hủy
          </Button>
          <Button
            type="button"
            variant={approving ? 'default' : 'destructive'}
            disabled={isPending}
            onClick={onSubmit}
          >
            {isPending ? (
              <Loader2 className="size-4 animate-spin" />
            ) : approving ? (
              <Check className="size-4" />
            ) : (
              <X className="size-4" />
            )}
            {approving ? 'Duyệt đơn' : 'Từ chối đơn'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

function StatsRow({
  stats,
  isLoading,
}: {
  stats?: AdminApplicationStats
  isLoading: boolean
}) {
  const items = [
    {
      label: 'Tổng đơn từ',
      value: stats?.totalApplications,
      icon: ClipboardList,
    },
    { label: 'Chờ duyệt', value: stats?.pendingApplications, icon: Clock },
    { label: 'Đã duyệt', value: stats?.approvedApplications, icon: ThumbsUp },
    { label: 'Từ chối', value: stats?.rejectedApplications, icon: ThumbsDown },
  ]

  return (
    <section className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
      {items.map((item) => (
        <div
          key={item.label}
          className="flex items-center gap-3 rounded-md border bg-background p-4"
        >
          <div className="flex size-9 shrink-0 items-center justify-center rounded-md bg-muted">
            <item.icon className="size-4 text-muted-foreground" />
          </div>
          <div className="min-w-0">
            <p className="text-xs text-muted-foreground">{item.label}</p>
            {isLoading ? (
              <Skeleton className="mt-1 h-6 w-12" />
            ) : (
              <p className="text-xl font-semibold tabular-nums">
                {item.value ?? 0}
              </p>
            )}
          </div>
        </div>
      ))}
    </section>
  )
}
