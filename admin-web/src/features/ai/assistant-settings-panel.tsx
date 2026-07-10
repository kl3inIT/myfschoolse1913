import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { toast } from 'sonner'
import { z } from 'zod'
import { Loader2, Save } from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { Separator } from '@/components/ui/separator'
import { Textarea } from '@/components/ui/textarea'
import {
  fetchAssistantSettings,
  updateAssistantSettings,
} from '@/lib/assistant'

function optionalNumber(min: number, max: number, label: string) {
  return z
    .string()
    .trim()
    .refine(
      (value) => {
        if (value === '') {
          return true
        }
        const parsed = Number(value)
        return !Number.isNaN(parsed) && parsed >= min && parsed <= max
      },
      { message: `${label} từ ${min} đến ${max}, hoặc bỏ trống` },
    )
}

const settingsSchema = z.object({
  chatModel: z
    .string()
    .trim()
    .min(1, 'Vui lòng nhập tên model')
    .max(80, 'Tên model tối đa 80 ký tự'),
  temperature: optionalNumber(0, 2, 'temperature'),
  topP: optionalNumber(0, 1, 'topP'),
  maxTokens: optionalNumber(1, 32768, 'maxTokens'),
  frequencyPenalty: optionalNumber(-2, 2, 'frequencyPenalty'),
  presencePenalty: optionalNumber(-2, 2, 'presencePenalty'),
  topK: z
    .number('topK phải là số')
    .int('topK phải là số nguyên')
    .min(1, 'topK tối thiểu là 1')
    .max(20, 'topK tối đa là 20'),
  similarityThreshold: optionalNumber(0, 1, 'Ngưỡng tương đồng'),
  memoryWindowMessages: z
    .number('Cửa sổ hội thoại phải là số')
    .int('Cửa sổ hội thoại phải là số nguyên')
    .min(2, 'Cửa sổ hội thoại tối thiểu là 2')
    .max(100, 'Cửa sổ hội thoại tối đa là 100'),
  extraInstructions: z
    .string()
    .trim()
    .max(2000, 'Hướng dẫn thêm tối đa 2000 ký tự'),
})

type SettingsForm = z.infer<typeof settingsSchema>

function toOptional(value: string): number | undefined {
  return value === '' ? undefined : Number(value)
}

function toFormText(value: number | null): string {
  return value == null ? '' : String(value)
}

export function AssistantSettingsPanel() {
  const queryClient = useQueryClient()

  const settingsQuery = useQuery({
    queryKey: ['admin-assistant', 'settings'],
    queryFn: fetchAssistantSettings,
  })

  const form = useForm<SettingsForm>({
    resolver: zodResolver(settingsSchema),
    defaultValues: {
      chatModel: '',
      temperature: '',
      topP: '',
      maxTokens: '',
      frequencyPenalty: '',
      presencePenalty: '',
      topK: 5,
      similarityThreshold: '',
      memoryWindowMessages: 30,
      extraInstructions: '',
    },
  })

  useEffect(() => {
    if (settingsQuery.data) {
      form.reset({
        chatModel: settingsQuery.data.chatModel,
        temperature: toFormText(settingsQuery.data.temperature),
        topP: toFormText(settingsQuery.data.topP),
        maxTokens: toFormText(settingsQuery.data.maxTokens),
        frequencyPenalty: toFormText(settingsQuery.data.frequencyPenalty),
        presencePenalty: toFormText(settingsQuery.data.presencePenalty),
        topK: settingsQuery.data.topK,
        similarityThreshold: toFormText(settingsQuery.data.similarityThreshold),
        memoryWindowMessages: settingsQuery.data.memoryWindowMessages,
        extraInstructions: settingsQuery.data.extraInstructions ?? '',
      })
    }
  }, [settingsQuery.data, form])

  const updateMutation = useMutation({
    mutationFn: updateAssistantSettings,
    onSuccess: (settings) => {
      toast.success('Đã lưu cài đặt trợ lý AI')
      queryClient.setQueryData(['admin-assistant', 'settings'], settings)
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Lưu cài đặt thất bại',
      )
    },
  })

  const disabled = settingsQuery.isPending

  return (
    <Card className="w-full">
      <CardHeader>
        <CardTitle>Cài đặt trợ lý AI</CardTitle>
        <CardDescription>
          Áp dụng ngay cho lượt chat tiếp theo của học sinh, không cần khởi
          động lại hệ thống. Các ô bỏ trống dùng giá trị mặc định của model.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Form {...form}>
          <form
            onSubmit={form.handleSubmit((values) =>
              updateMutation.mutate({
                chatModel: values.chatModel,
                temperature: toOptional(values.temperature),
                topP: toOptional(values.topP),
                maxTokens: toOptional(values.maxTokens),
                frequencyPenalty: toOptional(values.frequencyPenalty),
                presencePenalty: toOptional(values.presencePenalty),
                topK: values.topK,
                similarityThreshold: toOptional(values.similarityThreshold),
                memoryWindowMessages: values.memoryWindowMessages,
                extraInstructions: values.extraInstructions || undefined,
              }),
            )}
            className="space-y-5"
            noValidate
          >
            <p className="text-sm font-medium text-muted-foreground">
              Model sinh câu trả lời
            </p>
            <div className="grid gap-4 sm:grid-cols-3">
              <FormField
                control={form.control}
                name="chatModel"
                render={({ field }) => (
                  <FormItem className="sm:col-span-2">
                    <FormLabel>Model chat</FormLabel>
                    <FormControl>
                      <Input
                        autoComplete="off"
                        placeholder="VD: gpt-5.5"
                        disabled={disabled}
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>
                      Tên model OpenAI dùng để trả lời học sinh.
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="maxTokens"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>maxTokens</FormLabel>
                    <FormControl>
                      <Input
                        inputMode="numeric"
                        placeholder="Mặc định"
                        disabled={disabled}
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>Giới hạn độ dài trả lời.</FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <div className="grid gap-4 sm:grid-cols-4">
              <FormField
                control={form.control}
                name="temperature"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>temperature</FormLabel>
                    <FormControl>
                      <Input
                        inputMode="decimal"
                        placeholder="Mặc định"
                        disabled={disabled}
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>0–2. Độ "bay" của câu chữ.</FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="topP"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>topP</FormLabel>
                    <FormControl>
                      <Input
                        inputMode="decimal"
                        placeholder="Mặc định"
                        disabled={disabled}
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>0–1. Nucleus sampling.</FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="frequencyPenalty"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>frequencyPenalty</FormLabel>
                    <FormControl>
                      <Input
                        inputMode="decimal"
                        placeholder="Mặc định"
                        disabled={disabled}
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>-2–2. Giảm lặp từ.</FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="presencePenalty"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>presencePenalty</FormLabel>
                    <FormControl>
                      <Input
                        inputMode="decimal"
                        placeholder="Mặc định"
                        disabled={disabled}
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>-2–2. Khuyến khích ý mới.</FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <Separator />

            <p className="text-sm font-medium text-muted-foreground">
              Tìm kiếm kho tri thức (RAG) và hội thoại
            </p>
            <div className="grid gap-4 sm:grid-cols-3">
              <FormField
                control={form.control}
                name="topK"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>topK tài liệu</FormLabel>
                    <FormControl>
                      <Input
                        type="number"
                        min={1}
                        max={20}
                        disabled={disabled}
                        {...field}
                        onChange={(event) =>
                          field.onChange(event.target.valueAsNumber)
                        }
                      />
                    </FormControl>
                    <FormDescription>Số đoạn trích mỗi lần tìm.</FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="similarityThreshold"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Ngưỡng tương đồng</FormLabel>
                    <FormControl>
                      <Input
                        inputMode="decimal"
                        placeholder="Mặc định (0)"
                        disabled={disabled}
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>
                      0–1. Cao hơn = lọc gắt hơn.
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="memoryWindowMessages"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Cửa sổ hội thoại</FormLabel>
                    <FormControl>
                      <Input
                        type="number"
                        min={2}
                        max={100}
                        disabled={disabled}
                        {...field}
                        onChange={(event) =>
                          field.onChange(event.target.valueAsNumber)
                        }
                      />
                    </FormControl>
                    <FormDescription>
                      Số tin nhắn gần nhất model nhớ.
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <Separator />

            <FormField
              control={form.control}
              name="extraInstructions"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Hướng dẫn thêm cho trợ lý (tùy chọn)</FormLabel>
                  <FormControl>
                    <Textarea
                      className="min-h-28 resize-y"
                      placeholder="VD: Khi học sinh hỏi về học phí, hướng dẫn liên hệ phòng kế toán qua số 024-xxxx."
                      disabled={disabled}
                      {...field}
                    />
                  </FormControl>
                  <FormDescription>
                    Được thêm vào chỉ dẫn hệ thống của trợ lý ở mọi lượt chat.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="flex justify-end">
              <Button
                type="submit"
                disabled={disabled || updateMutation.isPending}
              >
                {updateMutation.isPending ? (
                  <Loader2 className="size-4 animate-spin" />
                ) : (
                  <Save className="size-4" />
                )}
                Lưu cài đặt
              </Button>
            </div>
          </form>
        </Form>
      </CardContent>
    </Card>
  )
}
