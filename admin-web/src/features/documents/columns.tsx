import type { ColumnDef } from '@tanstack/react-table'
import { Loader2, Trash2 } from 'lucide-react'
import { DataTableColumnHeader } from '@/components/data-table'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  documentCategoryLabels,
  documentIngestStatusLabels,
  formatFileSize,
  type AdminDocument,
} from '@/lib/documents'

export function documentColumns({
  deletingId,
  onDelete,
}: {
  deletingId?: string
  onDelete: (document: AdminDocument) => void
}): ColumnDef<AdminDocument>[] {
  return [
    {
      accessorKey: 'title',
      header: ({ column }) => (
        <DataTableColumnHeader column={column} title="Tài liệu" />
      ),
      cell: ({ row }) => (
        <div className="max-w-xs">
          <span className="block truncate font-medium">
            {row.original.title}
          </span>
          <p className="truncate text-xs text-muted-foreground">
            {row.original.fileName} · {formatFileSize(row.original.sizeBytes)}
          </p>
        </div>
      ),
    },
    {
      accessorKey: 'category',
      header: 'Loại',
      enableSorting: false,
      cell: ({ row }) => (
        <Badge variant="outline">
          {documentCategoryLabels[row.original.category]}
        </Badge>
      ),
    },
    {
      accessorKey: 'subjectName',
      header: 'Môn học',
      enableSorting: false,
      cell: ({ row }) => (
        <span className="text-muted-foreground">
          {row.original.subjectName ?? '—'}
        </span>
      ),
    },
    {
      accessorKey: 'ingestStatus',
      header: 'Trạng thái AI',
      enableSorting: false,
      cell: ({ row }) => {
        const status = row.original.ingestStatus
        if (status === 'INDEXED') {
          return (
            <Badge>
              {documentIngestStatusLabels[status]}
              {row.original.chunkCount != null
                ? ` · ${row.original.chunkCount} đoạn`
                : ''}
            </Badge>
          )
        }
        if (status === 'FAILED') {
          return (
            <Badge variant="destructive">
              {documentIngestStatusLabels[status]}
            </Badge>
          )
        }
        return (
          <Badge variant="outline">{documentIngestStatusLabels[status]}</Badge>
        )
      },
    },
    {
      accessorKey: 'updatedAt',
      header: ({ column }) => (
        <DataTableColumnHeader column={column} title="Cập nhật" />
      ),
      cell: ({ row }) => (
        <span className="whitespace-nowrap tabular-nums text-muted-foreground">
          {formatUpdatedAt(row.original.updatedAt)}
        </span>
      ),
    },
    {
      id: 'actions',
      header: () => <span className="sr-only">Thao tác</span>,
      enableSorting: false,
      cell: ({ row }) => (
        <div className="flex justify-end">
          <Button
            type="button"
            variant="outline"
            size="sm"
            disabled={deletingId === row.original.id}
            onClick={() => onDelete(row.original)}
          >
            {deletingId === row.original.id ? (
              <Loader2 className="size-3.5 animate-spin" />
            ) : (
              <Trash2 className="size-3.5" />
            )}
            Xóa
          </Button>
        </div>
      ),
    },
  ]
}

function formatUpdatedAt(updatedAt: string) {
  return new Date(updatedAt).toLocaleString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  })
}
