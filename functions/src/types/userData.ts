export type UserData = {
  name?: string
  photoURL?: string
  notifications?: Notification[]
}

type Notification = {
  [platform: string]: {
    lastUpdatedAt: string
    token: string
  }
}
