import { app, input, output, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";
import { AzureDevOpsApi } from "../apis/devops/azureDevops";
import { randomUUID } from "crypto";
import { TableClient } from "@azure/data-tables";

const tableClient = TableClient.fromConnectionString(getTableConnectionString(), 'AzureDevOpsProjectRequests');

const tableInput = input.table({
    tableName: 'AzureDevOpsProjectRequests',
    connection: 'TableConnectionString'
});

const tableOutput = output.table({
    tableName: 'AzureDevOpsProjectRequests',
    connection: 'TableConnectionString'
});

const queueOutput = output.storageQueue({
    queueName: 'new-requests-queue',
    connection: 'TableConnectionString',
});

interface ProjectRequest {
    PartitionKey: string;
    RowKey: string;
    id: string;
    organization: string;
    projectName: string;
    processTemplateId: string;
    url: string;
    status: "Pending" | "In Progress" | "Approved" | "Rejected" | "Failed" | "Completed";
    statusMessage?: string;
    createdAt: Date;
}

function getTableConnectionString(): string {
    return process.env["TableConnectionString"];
}

async function getOrganizations(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    return {
        jsonBody: await AzureDevOpsApi.getOrganizations()
    };
};

async function getProcessTemplates(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    const org = request.params.organization;

    return {
        jsonBody: await AzureDevOpsApi.getProcessTemplates(org)
    };
};

async function requestNewProject(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    const payload = (await request.json() as any);

    const org = payload.organization?.trim();
    const project = payload.projectName?.trim();
    const processId = payload.processId?.trim();

    const id = randomUUID();

    const projectRequest = {
        PartitionKey: org,
        RowKey: id,
        id: id,
        organization: org,
        projectName: project,
        processTemplateId: processId,
        status: 'Pending',
        url: '',
        createdAt: new Date()
    } as ProjectRequest;

    context.extraOutputs.set(tableOutput, projectRequest)
    context.extraOutputs.set(queueOutput, projectRequest);

    return {
        status: 201
    };
}

async function projectRequests(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    const entries = <ProjectRequest[]>(await context.extraInputs.get(tableInput));

    const requests = entries.map((entry: ProjectRequest) => {
        const { PartitionKey, RowKey, ...rest } = entry;
        return rest;
    });

    return {
        jsonBody: requests
    };
}

async function getProjectRequest(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    const partitionKey = request.params.partitionKey;
    const rowKey = request.params.rowKey;    

    const projectRequestEntity = await tableClient.getEntity<ProjectRequest>(partitionKey, rowKey);

    const { PartitionKey, RowKey, ...projectRequest } = projectRequestEntity;

    if (!projectRequestEntity) {
        return {
            status: 404
        };
    }

    return {
        jsonBody: projectRequest
    };
}

async function updateProjectRequest(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    const partitionKey = request.params.partitionKey;
    const rowKey = request.params.rowKey;
    const payload = <ProjectRequest>(await request.json());

    const projectRequest = await tableClient.getEntity<ProjectRequest>(partitionKey, rowKey);

    if (!projectRequest) {
        return {
            status: 404
        };
    }

    context.info(`Updating project request ${projectRequest.RowKey} with status '${payload.status}'`);

    const { url: updatedUrl, status: updatedStatus, statusMessage } = payload;

    const { PartitionKey, RowKey, ...existing } = projectRequest;

    tableClient.updateEntity({
        partitionKey: projectRequest.PartitionKey,
        rowKey: projectRequest.RowKey,
        ...existing,
        url: updatedUrl,
        status: updatedStatus,
        statusMessage: statusMessage,
    }, "Merge");

    return {
        status: 204
    };
}

async function createProject(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    const org = request.params.organization;
    const payload = (await request.json() as any);
    const projectName = payload.projectName;
    const processId = payload.processId;

    return {
        jsonBody: await AzureDevOpsApi.createProject(org, processId, projectName),
        status: 201
    };
};

async function removeProjectPermissions(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    const org = request.params.organization;
    const project = request.params.project;

    await AzureDevOpsApi.removeRepositoryCreationPermissions(org, project);

    return {
        status: 204
    };
}

app.http('organizations', {
    methods: ['GET'],
    handler: getOrganizations,
    authLevel: 'anonymous'
});

app.http('processes', {
    methods: ['GET'],
    route: 'organizations/{organization}/processes',
    handler: getProcessTemplates,
    authLevel: 'anonymous'
});

app.http('requestProject', {
    methods: ['POST'],
    route: 'project-requests',
    handler: requestNewProject,
    extraOutputs: [tableOutput, queueOutput],
    authLevel: 'anonymous'
});

app.http('projectRequests', {
    methods: ['GET'],
    route: 'project-requests',
    handler: projectRequests,
    extraInputs: [tableInput],
    authLevel: 'anonymous'
});

app.http('getProjectRequest', {
    methods: ['GET'],
    route: 'project-requests/{partitionKey}/{rowKey}',
    handler: getProjectRequest,
    authLevel: 'function'
});

app.http('updateProjectRequest', {
    methods: ['PATCH'],
    route: 'project-requests/{partitionKey}/{rowKey}',
    handler: updateProjectRequest,
    authLevel: 'function'
});

app.http('newProject', {
    methods: ['POST'],
    route: 'organizations/{organization}/projects',
    handler: createProject,
    authLevel: 'function'
});

app.http('removePermissions', {
    methods: ['DELETE'],
    route: 'organizations/{organization}/projects/{project}/permissions',
    handler: removeProjectPermissions,
    authLevel: 'function'
});