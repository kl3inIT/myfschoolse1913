import type { ColumnDef } from '@tanstack/react-table'
import { DataTableColumnHeader } from '@/components/data-table'
import type { AdminGrade } from '@/lib/grades'

export const gradeColumns: ColumnDef<AdminGrade>[] = [
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
    accessorKey: 'className',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Lớp" />
    ),
  },
  {
    accessorKey: 'subjectName',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Môn học" />
    ),
    cell: ({ row }) => (
      <div>
        <p>{row.original.subjectName}</p>
        <p className="text-xs text-muted-foreground">
          {row.original.subjectCode}
        </p>
      </div>
    ),
  },
  {
    id: 'semester',
    header: 'Học kỳ',
    enableSorting: false,
    cell: ({ row }) => (
      <div>
        <p>{row.original.semesterName}</p>
        <p className="text-xs text-muted-foreground">
          {row.original.academicYearName}
        </p>
      </div>
    ),
  },
  {
    accessorKey: 'formativeScore',
    header: () => <span className="block text-right">TX</span>,
    enableSorting: false,
    cell: ({ row }) => scoreCell(row.original.formativeScore),
  },
  {
    accessorKey: 'midtermScore',
    header: () => <span className="block text-right">GK</span>,
    enableSorting: false,
    cell: ({ row }) => scoreCell(row.original.midtermScore),
  },
  {
    accessorKey: 'finalScore',
    header: () => <span className="block text-right">CK</span>,
    enableSorting: false,
    cell: ({ row }) => scoreCell(row.original.finalScore),
  },
  {
    accessorKey: 'averageScore',
    header: ({ column }) => (
      <DataTableColumnHeader
        column={column}
        title="TB"
        className="-mr-2 ml-auto flex"
      />
    ),
    cell: ({ row }) => (
      <p className="text-right font-semibold tabular-nums">
        {formatScore(row.original.averageScore)}
      </p>
    ),
  },
  {
    accessorKey: 'updatedAt',
    header: 'Cập nhật',
    enableSorting: false,
    cell: ({ row }) => (
      <span className="whitespace-nowrap tabular-nums text-muted-foreground">
        {formatUpdatedAt(row.original.updatedAt)}
      </span>
    ),
  },
]

function scoreCell(value?: number) {
  return <p className="text-right tabular-nums">{formatScore(value)}</p>
}

function formatScore(value?: number) {
  return value != null ? value.toString() : '—'
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
