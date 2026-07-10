import { authorizedJson } from './api.ts'

export type AssistantSettings = {
  chatModel: string
  temperature: number | null
  topP: number | null
  maxTokens: number | null
  frequencyPenalty: number | null
  presencePenalty: number | null
  topK: number
  similarityThreshold: number | null
  memoryWindowMessages: number
  extraInstructions: string | null
  updatedAt: string | null
}

export type UpdateAssistantSettingsRequest = {
  chatModel: string
  temperature?: number
  topP?: number
  maxTokens?: number
  frequencyPenalty?: number
  presencePenalty?: number
  topK: number
  similarityThreshold?: number
  memoryWindowMessages: number
  extraInstructions?: string
}

export function fetchAssistantSettings() {
  return authorizedJson<AssistantSettings>('/api/admin/assistant/settings')
}

export function updateAssistantSettings(
  request: UpdateAssistantSettingsRequest,
) {
  return authorizedJson<AssistantSettings>('/api/admin/assistant/settings', {
    method: 'PUT',
    body: JSON.stringify(request),
  })
}
