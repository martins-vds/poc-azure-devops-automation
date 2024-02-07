import { useEffect, useState } from 'react'
import { Box, Button, Container, CssBaseline, Divider, FormControl, InputLabel, Link, MenuItem, Paper, Select, SelectChangeEvent, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, TextField, Typography } from '@mui/material'
import './App.css'
import { Organization, Process, ProjectRequest, api } from './api'

function App() {
  const [organization, setOrganization] = useState<Organization>('')
  const [organizations, setOrganizations] = useState<Organization[]>([]) // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10

  const [processId, setProcessId] = useState('')
  const [processes, setProcesses] = useState<Process[]>([])

  const [refreshTable, setRefreshTable] = useState(false)
  const [requests, setRequests] = useState<ProjectRequest[]>([])

  const [projectName, setProjectName] = useState('')

  const handleOrganizationChange = (event: SelectChangeEvent) => {
    setOrganization(event.target.value as string)
  }

  const handleProcessChange = (event: SelectChangeEvent) => {
    setProcessId(event.target.value as string)
  }

  const fetchRequests = async () => {
    try {
      const requests = await api.getProjectRequests()
      setRequests(requests)
    } catch {
      console.error('Error fetching requests')
      setRequests([])
    }
  }

  const handleSubmit = async () => {
    try {
      await api.submitProjectRequest(organization, processId, projectName)
      setRefreshTable(true)
    } catch {
      console.error('Error creating project request')
    }
  }

  useEffect(() => {
    const fetchOrganizations = async () => {
      try {
        const response = await api.getOrganizations()
        setOrganizations(response)
      } catch {
        console.error('Error fetching organizations')
        setOrganizations([])
      }
    }

    fetchOrganizations();
  }, [])

  useEffect(() => {
    const refreshTimer = setInterval(() => {
      fetchRequests()
    }, 5000)

    return () => clearInterval(refreshTimer)
  }, [])

  useEffect(() => {
    if (refreshTable === false) return

    fetchRequests()
    setRefreshTable(false)

  }, [refreshTable])

  useEffect(() => {
    if (organization === '') return

    const fetchProcessess = async () => {
      try {
        const processes = await api.getProcesses(organization)
        setProcesses(processes)
      } catch {
        console.error('Error fetching processes')
        setProcesses([])
      }
    }

    fetchProcessess()
  }, [organization])

  return (
    <>
      <CssBaseline />
      <Container maxWidth={false} sx={{
        width: '50vw',
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: "white",
      }}>
        <Typography variant="h6" sx={{
          marginTop: '20px',
        }} align='left'>
          Submit Project Request
        </Typography>
        <Box sx={{
          display: 'flex',
          flexDirection: 'row',
          marginTop: '20px',
          gap: '20px',
        }}>
          <FormControl sx={{
            flexGrow: 1,
          }}>
            <InputLabel id="organization-label">Organization</InputLabel>
            <Select
              labelId="organization"
              id="organization-select"
              value={organization}
              label="Organization"
              onChange={handleOrganizationChange}
            >
              {organizations.map((organization, index) => {
                return (
                  <MenuItem key={index} value={organization}>
                    {organization}
                  </MenuItem>
                )
              })}
            </Select>
          </FormControl>
          <FormControl sx={{
            flexGrow: 1,
          }}>
            <InputLabel id="process-label">Process Template</InputLabel>
            <Select
              labelId="process-label"
              id="process-select"
              value={processId}
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
          <FormControl sx={{
            flexGrow: 1,
          }}>
            <TextField
              label="Project Name"
              value={projectName}
              fullWidth={false}
              onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
                setProjectName(event.target.value);
              }}
            />
          </FormControl>
        </Box>
        <FormControl sx={{
          marginTop: '20px'
        }}>
          <Button variant="contained" onClick={handleSubmit} fullWidth={false}>Submit</Button>
        </FormControl>
        <Divider variant='fullWidth' sx={{
          marginTop: '20px',
        }} />
        <Typography variant="h6" sx={{
          marginTop: '20px',
        }} align='left'>
          Project Requests
        </Typography>
        <TableContainer sx={{
          marginTop: '20px'
        }} component={Paper} variant='outlined'>
          <Table sx={{ minWidth: 650 }} aria-label="simple table">
            <TableHead>
              <TableRow>
                <TableCell>Organization</TableCell>
                <TableCell>Project</TableCell>
                <TableCell>Link</TableCell>
                <TableCell>Status</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {requests.map((request) => {
                return (
                  <TableRow
                    key={request.id}
                    sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                  >
                    <TableCell>{request.organization}</TableCell>
                    <TableCell>{request.projectName}</TableCell>
                    <TableCell><Link href={request.url}
                      target="_blank"
                      rel="noopener noreferrer"
                    >{request.url}</Link></TableCell>
                    <TableCell>{request.status}</TableCell>
                  </TableRow>
                )
              })}
            </TableBody>
          </Table>
        </TableContainer>
      </Container>
    </>
  )
}

export default App
