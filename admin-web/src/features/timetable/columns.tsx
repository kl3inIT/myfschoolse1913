import type { ColumnDef } from '@tanstack/react-table'
import { DataTableColumnHeader } from '@/components/data-table'
import { Badge } from '@/components/ui/badge'
import {
  dayIndexLabels,
  slotTypeLabels,
  type AdminTimetableSlot,
} from '@/lib/timetable'

export const timetableColumns: ColumnDef<AdminTimetableSlot>[] = [
  {
    accessorKey: 'className',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Lớp" />
    ),
    cell: ({ row }) => (
      <div>
        <p className="font-medium">{row.original.className}</p>
        <p className="text-xs text-muted-foreground">
          {row.original.academicYearName}
        </p>
      </div>
    ),
  },
  {
    accessorKey: 'dayIndex',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Thứ" />
    ),
    cell: ({ row }) =>
      dayIndexLabels[row.original.dayIndex] ?? `Thứ ${row.original.dayIndex}`,
  },
  {
    accessorKey: 'lessonNumber',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Tiết" />
    ),
    cell: ({ row }) => (
      <span className="tabular-nums">{row.original.lessonNumber}</span>
    ),
  },
  {
    accessorKey: 'title',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Nội dung" />
    ),
    cell: ({ row }) => (
      <div>
        <p>{row.original.title}</p>
        {row.original.subjectCode ? (
          <p className="text-xs text-muted-foreground">
            {row.original.subjectCode}
          </p>
        ) : null}
      </div>
    ),
  },
  {
    accessorKey: 'slotType',
    header: 'Loại',
    enableSorting: false,
    cell: ({ row }) => slotTypeBadge(row.original),
  },
  {
    id: 'time',
    header: 'Giờ',
    enableSorting: false,
    cell: ({ row }) => (
      <span className="whitespace-nowrap tabular-nums">
        {row.original.startsAt} - {row.original.endsAt}
      </span>
    ),
  },
  {
    accessorKey: 'roomName',
    header: 'Phòng',
    enableSorting: false,
    cell: ({ row }) => row.original.roomName ?? '—',
  },
  {
    accessorKey: 'teacherName',
    header: 'Giáo viên',
    enableSorting: false,
    cell: ({ row }) => row.original.teacherName ?? '—',
  },
]

function slotTypeBadge(slot: AdminTimetableSlot) {
  if (slot.slotType === 'SUBJECT') {
    return <Badge variant="secondary">{slotTypeLabels.SUBJECT}</Badge>
  }
  if (slot.slotType === 'MEAL') {
    return <Badge variant="outline">{slotTypeLabels.MEAL}</Badge>
  }
  return <Badge variant="outline">{slotTypeLabels.ACTIVITY}</Badge>
}
