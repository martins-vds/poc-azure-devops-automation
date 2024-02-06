import { useEffect, useState } from 'react'
import { Box, Container, CssBaseline, FormControl, InputLabel, MenuItem, Select, SelectChangeEvent, Table, TableBody, TableCell, TableContainer, TableHead, TableRow } from '@mui/material'
import './App.css'

function App() {
  const [organization, setOrganization] = useState('')
  const [organizations, setOrganizations] = useState<string[]>([]) // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10

  const [process, setProcess] = useState('')
  const [processes, setProcesses] = useState<{
    id: string
    name: string
  }[]>([])

  const handleOrganizationChange = (event: SelectChangeEvent) => {
    setOrganization(event.target.value as string)
  }

  const handleProcessChange = (event: SelectChangeEvent) => {
    setProcess(event.target.value as string)
  }

  useEffect(() => {
    const fetchOrganizations = async () => {
      try {
        const response = await fetch('http://localhost:7071/api/organizations')
        const orgs = await response.json()
        setOrganizations(orgs)
      } catch {
        console.error('Error fetching organizations')
        setOrganizations([])
      }
    }

    fetchOrganizations();
  }, [])

  useEffect(() => {
    if (organization === '') return

    const fetchProcessess = async () => {
      try {
        const response = await fetch(`http://localhost:7071/api/organizations/${organization}/processes`)
        const processes = await response.json()

        setProcesses(processes)
      } catch {
        console.error('Error fetching processes')
      }
    }

    fetchProcessess()
  }, [organization])

  return (
    <>
      <CssBaseline />
      <Container maxWidth={false} sx={{
        width: '50%',
      }}>
        <Box sx={{ backgroundColor: "white", height: '100vh', width: '100%' }}>
          <FormControl sx={{
            width: '200px',
          }}>
            <InputLabel id="organization-label">Organization</InputLabel>
            <Select
              labelId="organization"
              id="organization-select"
              value={organization}
              label="Organization"
              onChange={handleOrganizationChange}
            >
              {organizations.map((organization) => {
                return (
                  <MenuItem value={organization}>
                    {organization}
                  </MenuItem>
                )
              })}
            </Select>
          </FormControl>
          <FormControl sx={{
            width: '200px',
            marginTop: '20px',
          }}>
            <InputLabel id="process-label">Process Template</InputLabel>
            <Select
              labelId="process-label"
              id="process-select"
              value={process}
              label="Process Template"
              onChange={handleProcessChange}
            >
              {processes.map((process) => {
                return (
                  <MenuItem value={process.id}>
                    {process.name}
                  </MenuItem>
                )
              })}
            </Select>
          </FormControl>
          <TableContainer sx={{
            marginTop: '20px',
          }}>
            <Table sx={{ minWidth: 650 }} aria-label="simple table">
              <TableHead>
                <TableRow>
                  <TableCell>Organization</TableCell>
                  <TableCell align="right">Project</TableCell>
                  <TableCell align="right">Link</TableCell>
                  <TableCell align="right">Status</TableCell>
                </TableRow>
                <TableBody>
                </TableBody>
              </TableHead>
            </Table>
          </TableContainer>
        </Box>
      </Container>
    </>
  )
}

export default App
