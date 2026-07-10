import { useState } from 'react'
import { FileText, Settings2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { DocumentManagementPage } from '@/features/documents/document-management-page'
import { AssistantSettingsPanel } from './assistant-settings-panel'

type AiView = 'settings' | 'documents'

export function AiManagementPage() {
  const [view, setView] = useState<AiView>('settings')

  return (
    <div className="flex h-[calc(100svh-8rem)] flex-col gap-4">
      <section className="flex items-center">
        <div className="inline-flex rounded-md border p-0.5">
          <Button
            type="button"
            variant="ghost"
            size="sm"
            aria-pressed={view === 'settings'}
            className={cn('h-7 px-2.5', view === 'settings' && 'bg-muted')}
            onClick={() => setView('settings')}
          >
            <Settings2 className="size-4" />
            Cấu hình
          </Button>
          <Button
            type="button"
            variant="ghost"
            size="sm"
            aria-pressed={view === 'documents'}
            className={cn('h-7 px-2.5', view === 'documents' && 'bg-muted')}
            onClick={() => setView('documents')}
          >
            <FileText className="size-4" />
            Kho tri thức
          </Button>
        </div>
      </section>

      <section className="flex min-h-0 min-w-0 flex-1 flex-col">
        {view === 'documents' ? (
          <DocumentManagementPage />
        ) : (
          <div className="min-h-0 flex-1 overflow-auto">
            <AssistantSettingsPanel />
          </div>
        )}
      </section>
    </div>
  )
}
