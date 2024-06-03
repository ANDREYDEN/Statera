export type UserData = {
  uid?: string
  name?: string
  photoURL?: string
  paymentInfo?: string
  notifications?: Notification[]
}

export type Notification = {
  [platform: string]: {
    lastUpdatedAt: string
    token: string
  }
}
