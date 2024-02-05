import axios from "axios"

export const devApi = axios.create({
    baseURL: "https://dev.azure.com",
    headers: {
        "Content-Type": "application/json",
        Authorization: `Basic ${Buffer.from(`:${process.env["AZURE_DEVOPS_PAT"]}`).toString("base64")}`,
    },
})

export const vsspApi = axios.create({
    baseURL: "https://vssps.dev.azure.com",
    headers: {
        "Content-Type": "application/json",
        Authorization: `Basic ${Buffer.from(`:${process.env["AZURE_DEVOPS_PAT"]}`, "utf8").toString("base64")}`,
    },
})

const errorHandler = (error: any) => {
    const statusCode = error.response?.status

    // logging only errors that are not 401
    if (statusCode && statusCode !== 401) {
        console.error(error)
    }

    return Promise.reject(error)
}

// registering the custom error handler to the
// "api" axios instance
devApi.interceptors.response.use(undefined, (error) => {
    return errorHandler(error)
})

vsspApi.interceptors.response.use(undefined, (error) => {
    return errorHandler(error)
})