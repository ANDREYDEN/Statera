import * as admin from 'firebase-admin'
import fetch from 'node-fetch'

export async function getLatestRelease(platform: string): Promise<Release> {
    const listApps = platform == 'android'
        ? admin.projectManagement().listAndroidApps()
        : admin.projectManagement().listIosApps()
    const apps = await listApps
    if (!apps || apps.length === 0) throw new Error(`No ${platform} apps found`)

    const app = apps[0]
    const appId = app.appId
    const projectNumber = app.appId.split(':')[1]

    const accessToken = await admin.app().options.credential?.getAccessToken()
    const response = await fetch(
        `https://firebaseappdistribution.googleapis.com/v1/projects/${projectNumber}/apps/${appId}/releases`,
        {
            headers: {
                Authorization: `Bearer ${accessToken?.access_token}`,
            }
        })
    if (!response.ok) {
        const error = await response.text()
        throw new Error(`Error getting latest release: ${error}`)
    }
    const result = await response.json()
    const releases = result.releases
    if (!releases || releases.length === 0) throw new Error(`No ${platform} releases found`)

    return releases[0]
}

type Release = {
    displayVersion: string
}