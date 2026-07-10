import type { ColumnDef } from '@tanstack/react-table'
import { Check, X } from 'lucide-react'
import { DataTableColumnHeader } from '@/components/data-table'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  applicationStatusLabels,
  applicationTypeLabels,
  type AdminApplication,
} from '@/lib/applications'

export function applicationColumns({
  onReview,
}: {
  onReview: (
    application: AdminApplication,
    decision: 'APPROVED' | 'REJECTED',
  ) => void
}): ColumnDef<AdminApplication>[] {
  return [
    {
      accessorKey: 'studentCode',
      header: ({ column }) => (
        <DataTableColumnHeader column={column} title="Học sinh" />
      ),
      cell: ({ row }) => (
        <div>
          <p className="font-medium">{row.original.fullName}</p>
          <p className="text-xs text-muted-foreground">
            {row.original.studentCode} · {row.original.className}
          </p>
        </div>
      ),
    },
    {
      accessorKey: 'type',
      header: 'Loại đơn',
      enableSorting: false,
      cell: ({ row }) => (
        <Badge variant="outline">
          {applicationTypeLabels[row.original.type]}
        </Badge>
      ),
    },
    {
      accessorKey: 'reason',
      header: 'Lý do',
      enableSorting: false,
      cell: ({ row }) => (
        <div className="max-w-xs">
          <p className="truncate" title={row.original.reason}>
            {row.original.reason}
          </p>
          {row.original.details ? (
            <p
              className="truncate text-xs text-muted-foreground"
              title={row.original.details}
            >
              {row.original.details}
            </p>
          ) : null}
        </div>
      ),
    },
    {
      accessorKey: 'targetDate',
      header: ({ column }) => (
        <DataTableColumnHeader column={column} title="Ngày áp dụng" />
      ),
      cell: ({ row }) => (
        <span className="whitespace-nowrap tabular-nums">
          {formatDate(row.original.targetDate)}
          {row.original.requestedTime
            ? ` · ${row.original.requestedTime.slice(0, 5)}`
            : ''}
        </span>
      ),
    },
    {
      accessorKey: 'createdAt',
      header: ({ column }) => (
        <DataTableColumnHeader column={column} title="Gửi lúc" />
      ),
      cell: ({ row }) => (
        <span className="whitespace-nowrap tabular-nums text-muted-foreground">
          {formatInstant(row.original.createdAt)}
        </span>
      ),
    },
    {
      accessorKey: 'status',
      header: 'Trạng thái',
      enableSorting: false,
      cell: ({ row }) => (
        <div>
          {statusBadge(row.original)}
          {row.original.reviewerNote ? (
            <p
              className="mt-0.5 max-w-40 truncate text-xs text-muted-foreground"
              title={row.original.reviewerNote}
            >
              {row.original.reviewerNote}
            </p>
          ) : null}
        </div>
      ),
    },
    {
      id: 'actions',
      header: () => <span className="sr-only">Thao tác</span>,
      enableSorting: false,
      cell: ({ row }) =>
        row.original.status === 'PENDING' ? (
          <div className="flex justify-end gap-1">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => onReview(row.original, 'APPROVED')}
            >
              <Check className="size-3.5" />
              Duyệt
            </Button>
            <Button
              type="button"
              variant="ghost"
              size="sm"
              className="text-destructive hover:text-destructive"
              onClick={() => onReview(row.original, 'REJECTED')}
            >
              <X className="size-3.5" />
              Từ chối
            </Button>
          </div>
        ) : null,
    },
  ]
}

function statusBadge(application: AdminApplication) {
  if (application.status === 'PENDING') {
    return <Badge variant="secondary">{applicationStatusLabels.PENDING}</Badge>
  }
  if (application.status === 'APPROVED') {
    return <Badge>{applicationStatusLabels.APPROVED}</Badge>
  }
  return <Badge variant="destructive">{applicationStatusLabels.REJECTED}</Badge>
}

function formatDate(date: string) {
  return new Date(`${date}T00:00:00`).toLocaleDateString('vi-VN')
}

function formatInstant(instant: string) {
  return new Date(instant).toLocaleString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  })
}
