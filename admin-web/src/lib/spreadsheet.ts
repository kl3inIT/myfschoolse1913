import * as XLSX from 'xlsx'

export const spreadsheetDropzoneAccept = {
  'text/csv': ['.csv'],
  'text/plain': ['.csv'],
  'application/vnd.ms-excel': ['.csv', '.xls'],
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': [
    '.xlsx',
  ],
}

export async function fileToCsvText(file: File) {
  if (file.name.toLowerCase().endsWith('.csv')) {
    return file.text()
  }

  const workbook = XLSX.read(await file.arrayBuffer())
  const firstSheetName = workbook.SheetNames[0]
  if (!firstSheetName) {
    throw new Error('File Excel không có sheet dữ liệu')
  }

  return XLSX.utils.sheet_to_csv(workbook.Sheets[firstSheetName])
}
