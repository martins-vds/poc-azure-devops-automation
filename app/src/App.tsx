import { useEffect, useState } from 'react'
import { Box, Button, Container, CssBaseline, FormControl, InputLabel, Link, MenuItem, Select, SelectChangeEvent, Stack, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, TextField, Typography } from '@mui/material'
import './App.css'
import { Organization, Process, ProjectRequest, api } from './api'

function App() {
  const [organization, setOrganization] = useState<Organization>('')
  const [organizations, setOrganizations] = useState<Organization[]>([]) // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10

  const [process, setProcess] = useState('')
  const [processes, setProcesses] = useState<Process[]>([])

  const [refreshTable, setRefreshTable] = useState(false)
  const [requests, setRequests] = useState<ProjectRequest[]>([])

  const [projectName, setProjectName] = useState('')

  const handleOrganizationChange = (event: SelectChangeEvent) => {
    setOrganization(event.target.value as string)
  }

  const handleProcessChange = (event: SelectChangeEvent) => {
    setProcess(event.target.value as string)
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

  const handleSubmit = async () => {
    try {
      await api.submitProjectRequest(organization, process, projectName)
      setRefreshTable(true)
    } catch {
      console.error('Error creating project request')
    }
  }

  return (
    <>
      <CssBaseline />
      <Container maxWidth={false} sx={{
        width: '50vw',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: "white",
      }}>
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
        <FormControl sx={{
          marginTop: '20px'
        }}>
          <TextField
            label="Project Name"
            value={projectName}
            onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
              setProjectName(event.target.value);
            }}
          />
        </FormControl>
        <FormControl sx={{
          marginTop: '20px'
        }}>
          <Button variant="contained" onClick={handleSubmit}>Submit</Button>
        </FormControl>
        <Typography variant="h6" sx={{
          marginTop: '20px',
        }}>
          Project Requests
        </Typography>
        <TableContainer sx={{
          marginTop: '20px'
        }}>
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
                    <TableCell>{request.project}</TableCell>
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
