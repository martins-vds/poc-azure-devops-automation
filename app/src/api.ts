const BASE_URL = import.meta.env.VITE_API_URL ?? '';

export interface ProjectRequest {
    id: string;
    organization: string;
    projectName: string;
    processTemplateId: string;
    url: string;
    status: "Pending" | "Approved" | "Rejected" | "Failed";
    createdAt: Date;
}

export interface Process {
    id: string;
    name: string;
}

export type Organization = string;

async function getOrganizations(): Promise<string[]> {
    const response = await fetch(`${BASE_URL}/api/organizations`);
    return response.json();
}

async function getProcesses(organization: string): Promise<Process[]> {
    const response = await fetch(`${BASE_URL}/api/organizations/${organization}/processes`);
    return response.json();
}

async function getProjectRequests(): Promise<ProjectRequest[]> {
    const response = await fetch(`${BASE_URL}/api/project-requests`);
    return response.json();
}

async function submitProjectRequest(organization: string, processId: string, projectName: string): Promise<void> {
    const response = await fetch(`${BASE_URL}/api/project-requests`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            organization: organization,
            projectName: projectName,
            processId: processId
        })
    });

    if (!response.ok) {
        throw new Error('Failed to submit project request');
    }
}

export const api = {
    getOrganizations,
    getProcesses,
    getProjectRequests,
    submitProjectRequest
}