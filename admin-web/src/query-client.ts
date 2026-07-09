import { QueryCache, QueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
      retry: 1,
    },
  },
  queryCache: new QueryCache({
    onError: (error) => {
      toast.error(error instanceof Error ? error.message : 'Không tải được dữ liệu')
    },
  }),
})
