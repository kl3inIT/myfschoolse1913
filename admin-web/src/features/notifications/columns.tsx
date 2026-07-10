import type { ColumnDef } from '@tanstack/react-table'
import { Loader2, Pin, Undo2 } from 'lucide-react'
import { DataTableColumnHeader } from '@/components/data-table'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  notificationAudienceLabels,
  notificationCategoryLabels,
  type AdminNotification,
} from '@/lib/notifications'

export function notificationColumns({
  deactivatingId,
  onDeactivate,
}: {
  deactivatingId?: string
  onDeactivate: (notification: AdminNotification) => void
}): ColumnDef<AdminNotification>[] {
  return [
    {
      accessorKey: 'title',
      header: ({ column }) => (
        <DataTableColumnHeader column={column} title="Tiêu đề" />
      ),
      cell: ({ row }) => (
        <div
          className={
            row.original.active ? 'max-w-xs' : 'max-w-xs opacity-60'
          }
        >
          <div className="flex items-center gap-1.5">
            {row.original.pinned ? (
              <Pin className="size-3.5 shrink-0 text-muted-foreground" />
            ) : null}
            <span className="truncate font-medium">{row.original.title}</span>
          </div>
          <p className="truncate text-xs text-muted-foreground">
            {row.original.body}
          </p>
        </div>
      ),
    },
    {
      accessorKey: 'category',
      header: 'Phân loại',
      enableSorting: false,
      cell: ({ row }) => (
        <Badge variant="outline">
          {notificationCategoryLabels[row.original.category]}
        </Badge>
      ),
    },
    {
      accessorKey: 'audience',
      header: 'Đối tượng',
      enableSorting: false,
      cell: ({ row }) => (
        <span className="text-muted-foreground">
          {notificationAudienceLabels[row.original.audience]}
        </span>
      ),
    },
    {
      accessorKey: 'publishedAt',
      header: ({ column }) => (
        <DataTableColumnHeader column={column} title="Đăng lúc" />
      ),
      cell: ({ row }) => (
        <span className="whitespace-nowrap tabular-nums text-muted-foreground">
          {formatPublishedAt(row.original.publishedAt)}
        </span>
      ),
    },
    {
      accessorKey: 'active',
      header: 'Trạng thái',
      enableSorting: false,
      cell: ({ row }) =>
        row.original.active ? (
          <Badge>Đang hiển thị</Badge>
        ) : (
          <Badge variant="outline">Đã thu hồi</Badge>
        ),
    },
    {
      id: 'actions',
      header: () => <span className="sr-only">Thao tác</span>,
      enableSorting: false,
      cell: ({ row }) =>
        row.original.active ? (
          <div className="flex justify-end">
            <Button
              type="button"
              variant="outline"
              size="sm"
              disabled={deactivatingId === row.original.id}
              onClick={() => onDeactivate(row.original)}
            >
              {deactivatingId === row.original.id ? (
                <Loader2 className="size-3.5 animate-spin" />
              ) : (
                <Undo2 className="size-3.5" />
              )}
              Thu hồi
            </Button>
          </div>
        ) : null,
    },
  ]
}

function formatPublishedAt(publishedAt: string) {
  return new Date(publishedAt).toLocaleString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  })
}
