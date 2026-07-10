export function splitCsvLine(line: string) {
  const values: string[] = []
  let current = ''
  let inQuotes = false

  for (let index = 0; index < line.length; index += 1) {
    const char = line[index]
    const nextChar = line[index + 1]

    if (char === '"' && inQuotes && nextChar === '"') {
      current += '"'
      index += 1
      continue
    }

    if (char === '"') {
      inQuotes = !inQuotes
      continue
    }

    if (char === ',' && !inQuotes) {
      values.push(current)
      current = ''
      continue
    }

    current += char
  }

  values.push(current)
  return values
}

export function csvRecords(csv: string) {
  const lines = csv
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)

  if (lines.length === 0) {
    return { headers: [] as string[], records: [] as Record<string, string>[] }
  }

  const headers = splitCsvLine(lines[0]).map((header) => header.trim())
  const records = lines.slice(1).map((line) => {
    const values = splitCsvLine(line)
    return Object.fromEntries(
      headers.map((header, index) => [header, values[index]?.trim() ?? '']),
    )
  })

  return { headers, records }
}
