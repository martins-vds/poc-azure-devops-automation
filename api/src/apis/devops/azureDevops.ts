import { devApi, vsspApi } from "./axiosConfigs";

export interface Account {
    AccountId: string;
    NamespaceId: string;
    AccountName: string;
    OrganizationName: null;
    AccountType: number;
    AccountOwner: string;
    CreatedBy: string;
    CreatedDate: Date;
    AccountStatus: number;
    StatusReason: null;
    LastUpdatedBy: string;
    Properties: any;
}

export interface Process {
    id: string;
    name: string;
}



const getOrganizations = async function (): Promise<string[]> {
    const profile = await vsspApi.request({
        url: "/_apis/profile/profiles/me",
        method: "GET",
    });

    const memberId = profile.data.id;

    const accounts = await vsspApi.request<Account[]>({
        url: `/_apis/accounts?memberId=${memberId}`,
        method: "GET",
    });

    return accounts.data.map((account) => account.AccountName);
}

const getProcessTemplates = async function (organization: string): Promise<Process[]> {
    const processTemplates = await devApi.request({
        url: `/${organization}/_apis/process/processes?api-version=7.2-preview.1`,
        method: "GET",
    });

    return processTemplates.data.value.map((processTemplate: Process) => {
        return {
            id: processTemplate.id,
            name: processTemplate.name
        }
    });
}

const createProject = async function (organization: string, processId: string, projectName: string): Promise<void> {
    const project = await getProject(organization, projectName);

    if (project) {
        return project;
    }

    const operation = await devApi.request({
        url: `/${organization}/_apis/projects?api-version=7.2-preview.4`,
        method: "POST",
        data: {
            name: projectName,
            description: "Created by Azure Function",
            visibility: "private",
            capabilities: {
                versioncontrol: {
                    sourceControlType: "Git"
                },
                processTemplate: {
                    templateTypeId: processId
                }
            }
        }
    });

    await waitOperation(operation.data.url);

    return await getProject(organization, projectName);
}

const removeRepositoryCreationPermissions = async function (organization: string, projectName: string): Promise<void> {
    const project = await getProject(organization, projectName);
    const projectDescriptor = await getProjectDescriptor(organization, project.id);
    const groups = await getProjectGroups(organization, projectDescriptor);
    const projectValidUsersGroup = groups.find((group: any) => group.displayName === "Project Valid Users");
    const projectValidUsersGroupIdentity = await getIdentity(organization, projectValidUsersGroup.descriptor);
    const gitSecurityNamespace = await getSecurityNamespace(organization, "Git Repositories");
    const createRepositoryPermission = gitSecurityNamespace.actions.find((action: any) => action.name === "CreateRepository");
    const token = `repoV2/${project.id}`
    const deny = true;

    updateAccessControlEntries(organization, gitSecurityNamespace.namespaceId, token, projectValidUsersGroupIdentity.descriptor, createRepositoryPermission.bit, deny);
}

const waitOperation = async function (operationUrl: string): Promise<void> {
    await new Promise((resolve: any, reject: any) => {
        const interval = setInterval(async () => {
            try {
                const result = await devApi.request({
                    url: operationUrl,
                    method: "GET"
                });

                if (result.data.status === "succeeded") {
                    clearInterval(interval);
                    resolve();
                } else if (result.data.status === "failed" || result.data.status === "cancelled") {
                    clearInterval(interval);
                    reject();
                }
            } catch (error: any) {
                clearInterval(interval);
                reject(error);
            }
        }, 1000);
    });

}

const getProject = async function (organization: string, projectName: string): Promise<any> {
    try {
        const newProject = await devApi.request({
            url: `/${organization}/_apis/projects/${projectName}?api-version=7.2-preview.4`,
            method: "GET"
        });

        return newProject.data;
    } catch (error) {
        return null;
    }
}

const getProjectDescriptor = async function (organization: string, storageKey: string): Promise<string> {
    const project = await vsspApi.request({
        url: `/${organization}/_apis/graph/descriptors/${storageKey}`,
        method: "GET"
    });

    return project.data.value;
}

const getProjectGroups = async function (organization: string, projectScopeDescriptor: string): Promise<any> {
    const groups = await vsspApi.request({
        url: `/${organization}/_apis/graph/groups?scopeDescriptor=${projectScopeDescriptor}&api-version=7.1-preview.1`,
        method: "GET"
    });

    return groups.data.value;

}

const getIdentity = async function (organization: string, subjectDescriptor: string): Promise<any> {
    const identity = await vsspApi.request({
        url: `/${organization}/_apis/identities?subjectDescriptors=${subjectDescriptor}&queryMembership=None&api-version=7.1-preview.1`,
        method: "GET"
    });

    return identity.data.value ? identity.data.value[0] : null;
}

const getSecurityNamespace = async function (organization: string, namespace: string): Promise<any> {
    const securityNamespace = await devApi.request({
        url: `/${organization}/_apis/securitynamespaces?api-version=7.1-preview.1`,
        method: "GET"
    });

    return securityNamespace.data.value.find((ns: any) => ns.displayName === namespace);
}

const updateAccessControlEntries = async function (organization: string, securityNamespaceId: string, token: string, descriptor: string, permissionBit: number, deny: boolean): Promise<void> {
    const body = {
        token: token,
        merge: true,
        accessControlEntries: [
            {
                descriptor: descriptor,
                allow: (deny ? 0 : permissionBit),
                deny: (deny ? permissionBit : 0)
            }
        ]
    };

    await devApi.request({
        url: `/${organization}/_apis/accesscontrolentries/${securityNamespaceId}?api-version=7.1-preview.1`,
        method: "POST",
        data: body
    });
}

export const AzureDevOpsApi = {
    getOrganizations,
    getProcessTemplates,
    createProject,
    removeRepositoryCreationPermissions
}