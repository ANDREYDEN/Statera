export type Item = {
    name: string
    assignees: AssigneeDecision[]
}

type AssigneeDecision = {
    uid: string
    parts: number
}
