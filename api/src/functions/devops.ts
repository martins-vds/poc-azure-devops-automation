import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";
import { AzureDevOpsApi } from "../apis/devops/azureDevops";

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

async function createProject(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    const org = request.params.organization;
    const payload = (await request.json() as any);
    const projectName = payload.projectName;
    const processId = payload.processId;

    return {
        jsonBody: await AzureDevOpsApi.createProject(org, projectName, processId),
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
    handler: getOrganizations
});

app.http('processes', {
    methods: ['GET'],
    route: 'organizations/{organization}/processes',
    handler: getProcessTemplates
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