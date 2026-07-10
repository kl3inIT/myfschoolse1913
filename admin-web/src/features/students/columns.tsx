import { Link } from '@tanstack/react-router'
import type { ColumnDef } from '@tanstack/react-table'
import { Eye, Pencil } from 'lucide-react'
import { DataTableColumnHeader } from '@/components/data-table'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import type { AdminStudent } from '@/lib/students'

export const studentColumns: ColumnDef<AdminStudent>[] = [
  {
    accessorKey: 'studentCode',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Mã học sinh" />
    ),
    cell: ({ row }) => (
      <span className="font-medium">{row.original.studentCode}</span>
    ),
  },
  {
    accessorKey: 'fullName',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Họ và tên" />
    ),
  },
  {
    accessorKey: 'phoneNumber',
    header: 'Số điện thoại',
    enableSorting: false,
    cell: ({ row }) => (
      <span className="tabular-nums">{row.original.phoneNumber}</span>
    ),
  },
  {
    accessorKey: 'className',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Lớp" />
    ),
  },
  {
    accessorKey: 'status',
    header: 'Trạng thái',
    enableSorting: false,
    cell: ({ row }) => studentStatusBadge(row.original),
  },
  {
    id: 'actions',
    header: () => <span className="sr-only">Thao tác</span>,
    enableSorting: false,
    cell: ({ row }) => (
      <div
        className="flex justify-end gap-1"
        onClick={(event) => event.stopPropagation()}
        onKeyDown={(event) => event.stopPropagation()}
      >
        <Button
          asChild
          type="button"
          variant="ghost"
          size="icon"
          className="size-8"
          aria-label="Xem chi tiết"
        >
          <Link
            to="/students/$studentId"
            params={{ studentId: row.original.id }}
          >
            <Eye className="size-4" />
          </Link>
        </Button>
        <Button
          asChild
          type="button"
          variant="ghost"
          size="icon"
          className="size-8"
          aria-label="Chỉnh sửa"
        >
          <Link
            to="/students/$studentId"
            params={{ studentId: row.original.id }}
            search={{ edit: true }}
          >
            <Pencil className="size-4" />
          </Link>
        </Button>
      </div>
    ),
  },
]

function studentStatusBadge(student: AdminStudent) {
  if (!student.accountEnabled) {
    return <Badge variant="destructive">Đã khóa</Badge>
  }
  if (student.status === 'Đang học') {
    return <Badge>Đang học</Badge>
  }
  return <Badge variant="outline">{student.status}</Badge>
}
