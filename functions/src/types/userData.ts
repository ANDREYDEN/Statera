export type UserData = {
  name?: string
  photoURL?: string
  paymentMethod?: string
  notifications?: Notification[]
}

type Notification = {
  [platform: string]: {
    lastUpdatedAt: string
    token: string
  }
}
