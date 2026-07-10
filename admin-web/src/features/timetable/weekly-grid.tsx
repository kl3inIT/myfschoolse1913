import { CalendarDays } from 'lucide-react'
import {
  Empty,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from '@/components/ui/empty'
import { Skeleton } from '@/components/ui/skeleton'
import { cn } from '@/lib/utils'
import { dayIndexLabels, type AdminTimetableSlot } from '@/lib/timetable'

const allDays = [1, 2, 3, 4, 5, 6, 7]

export function TimetableWeeklyGrid({
  slots,
  isLoading,
}: {
  slots: AdminTimetableSlot[]
  isLoading: boolean
}) {
  if (isLoading) {
    return (
      <div className="grid gap-2 p-4 sm:grid-cols-3 xl:grid-cols-6">
        {Array.from({ length: 18 }, (_, index) => (
          <Skeleton key={index} className="h-20" />
        ))}
      </div>
    )
  }

  const days = allDays.filter((day) =>
    slots.some((slot) => slot.dayIndex === day),
  )
  const lessons = [...new Set(slots.map((slot) => slot.lessonNumber))].sort(
    (a, b) => a - b,
  )

  if (days.length === 0) {
    return (
      <Empty className="min-h-[360px] border-0">
        <EmptyHeader>
          <EmptyMedia variant="icon">
            <CalendarDays />
          </EmptyMedia>
          <EmptyTitle>Lớp này chưa có thời khóa biểu</EmptyTitle>
          <EmptyDescription>
            Nhập CSV/Excel để tạo tiết học cho lớp trong học kỳ đã chọn.
          </EmptyDescription>
        </EmptyHeader>
      </Empty>
    )
  }

  const slotByKey = new Map(
    slots.map((slot) => [`${slot.dayIndex}-${slot.lessonNumber}`, slot]),
  )

  return (
    <div className="min-h-0 flex-1 overflow-auto p-3">
      <div
        className="grid min-w-[720px] gap-1.5"
        style={{
          gridTemplateColumns: `48px repeat(${days.length}, minmax(140px, 1fr))`,
        }}
      >
        <div />
        {days.map((day) => (
          <div
            key={day}
            className="rounded-md bg-muted px-2 py-1.5 text-center text-xs font-semibold"
          >
            {dayIndexLabels[day]}
          </div>
        ))}

        {lessons.map((lesson) => (
          <LessonRow
            key={lesson}
            lesson={lesson}
            days={days}
            slotByKey={slotByKey}
          />
        ))}
      </div>
    </div>
  )
}

function LessonRow({
  lesson,
  days,
  slotByKey,
}: {
  lesson: number
  days: number[]
  slotByKey: Map<string, AdminTimetableSlot>
}) {
  return (
    <>
      <div className="flex items-center justify-center rounded-md bg-muted text-xs font-semibold tabular-nums">
        {lesson}
      </div>
      {days.map((day) => {
        const slot = slotByKey.get(`${day}-${lesson}`)
        if (!slot) {
          return (
            <div
              key={day}
              className="min-h-16 rounded-md border border-dashed border-border/60"
            />
          )
        }
        return <SlotCell key={day} slot={slot} />
      })}
    </>
  )
}

function SlotCell({ slot }: { slot: AdminTimetableSlot }) {
  return (
    <div
      className={cn(
        'min-h-16 space-y-0.5 rounded-md border border-l-2 p-2',
        slot.slotType === 'SUBJECT' && 'border-l-primary bg-primary/[0.05]',
        slot.slotType === 'MEAL' &&
          'border-l-muted-foreground/50 bg-muted/60',
        slot.slotType === 'ACTIVITY' && 'border-l-sky-500 bg-sky-500/[0.06]',
      )}
    >
      <p className="truncate text-xs font-medium" title={slot.title}>
        {slot.title}
      </p>
      <p className="text-[11px] tabular-nums text-muted-foreground">
        {slot.startsAt} - {slot.endsAt}
      </p>
      {slot.roomName || slot.teacherName ? (
        <p className="truncate text-[11px] text-muted-foreground">
          {[slot.roomName, slot.teacherName].filter(Boolean).join(' · ')}
        </p>
      ) : null}
    </div>
  )
}
